import 'dart:convert';

import 'package:com.luckus7.lucs/service/messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class WebViewController extends GetxController {
  PackageInfo packageInfo = Get.find();
  MessagingService messagingService = Get.find();
  final cookieManager = CookieManager.instance();
  final wcookieManager = WebviewCookieManager();

  late InAppWebViewGroupOptions _initialOptions;
  final controllers = <InAppWebViewController>[];

  // ignore: close_sinks
  final progress = BehaviorSubject<int>.seeded(0);

  InAppWebViewController get rootController => controllers.first;

  InAppWebViewController get currentController => controllers.last;

  WebViewController() {
    _initialOptions = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        transparentBackground: true,
        // applicationNameForUserAgent:
        //     "${FkUserAgent.userAgent!} Lucs/${packageInfo.buildNumber} (PushToken ${messagingService.token.value})",
        supportZoom: false,
        incognito: false,
        javaScriptCanOpenWindowsAutomatically: true,
        // useShouldOverrideUrlLoading: true,
        userAgent:
            "${FkUserAgent.userAgent!} Lucs/${packageInfo.buildNumber} (PushToken ${messagingService.token.value})",
      ),
      ios: IOSInAppWebViewOptions(
        allowsAirPlayForMediaPlayback: false,
        allowsBackForwardNavigationGestures: false,
        allowsInlineMediaPlayback: true,
        sharedCookiesEnabled: false,
      ),
      android: AndroidInAppWebViewOptions(
        builtInZoomControls: false,
        useHybridComposition: true,
        supportMultipleWindows: true,
      ),
    );
  }

  onWebViewCreated(InAppWebViewController controller) {
    controllers.add(controller);
  }

  onProgressChanged(InAppWebViewController controller, int progress) {
    // debugPrint(progress.toString());
    this.progress.add(progress);
    if (progress == 100) {
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        if (this.progress.value == 100) {
          this.progress.add(0);
        }
        return null;
      });
    }
  }

  onConsoleMessage(
      InAppWebViewController controller, ConsoleMessage consoleMessage) {
    // debugPrint(consoleMessage.message);
  }

  onLoadError(
      InAppWebViewController controller, Uri? url, int code, String message) {}

  onLoadStop(InAppWebViewController controller, Uri? url) async {
    //   if (url != null) {
    //     debugPrint(url.toString());
    //     final cookies = await cookieManager.getCookies(url: url);
    //     debugPrint(cookies.length.toString());
    //     debugPrint(jsonEncode(cookies));
    //
    //     final gotCookies = await wcookieManager.getCookies(url.toString());
    //     print(gotCookies.length.toString());
    //     for (var item in gotCookies) {
    //       print(item);
    //     }
    //   }
  }

  Widget newWebView(BuildContext context,
      {URLRequest? initialUrlRequest,
      CreateWindowAction? createWindowAction,
      List<Cookie> cookies = const []}) {
    InAppWebViewController? _controller;

    return WillPopScope(
      onWillPop: () async {
        if (_controller == null) {
          return true;
        }

        final canGoBack = await _controller!.canGoBack();

        if (canGoBack) {
          _controller?.goBack();
          return false;
        } else {
          if (_controller == rootController) {
            return true;
          } else {
            _controller?.evaluateJavascript(source: "window.close()");
            return false;
          }
        }
      },
      child: InAppWebView(
        key: UniqueKey(),
        // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[Factory(() => EagerGestureRecognizer())].toSet(),
        windowId: createWindowAction?.windowId,
        initialUrlRequest: createWindowAction != null
            ? createWindowAction.request
            : initialUrlRequest,
        // initialHeaders: {},
        initialOptions: _initialOptions,
        onWebViewCreated: (controller) {
          controllers.add(controller);
          _controller = controller;
        },
        onJsAlert: (controller, jsAlertRequest) {
          return Future.value(JsAlertResponse());
        },
        onLoadStop: onLoadStop,
        onLoadError: onLoadError,
        onProgressChanged: onProgressChanged,
        onConsoleMessage: onConsoleMessage,
        onCreateWindow: (controller, createWindowRequest) async {
          final url = createWindowRequest.request.url.toString().toLowerCase();
          if (url.endsWith("png") ||
              url.endsWith("jpg") ||
              url.endsWith("jpeg")) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                contentPadding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                content: Image.network(
                  createWindowRequest.request.url.toString(),
                  width: MediaQuery.of(context).size.width * 0.9,
                  // height: MediaQuery.of(context).size.height * 0.9,
                ),
              ),
            );
          } else {
            showModalBottomSheet(
              elevation: 8,
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0),
                  ),
                ),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: newWebView(context,
                        createWindowAction: createWindowRequest)),
              ),
            );
          }

/*
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.only(top:32),
              content:
                  SizedBox(width: MediaQuery.of(context).size.width, child: newWebView(context, createWindowAction: createWindowRequest)),
            ),
          );
*/

          return true;
        },
        onCloseWindow: (controller) {
          controllers.remove(controller);
          Navigator.of(context).pop();
        },
        onLoadStart: (controller, url) {
          // print("onLoadStart: " + url.toString());
        },
        shouldInterceptFetchRequest: (controller, fetchRequest) {
          print("shouldInterceptFetchRequest");
          print(jsonEncode(fetchRequest.headers));
          return Future.value(fetchRequest);
        },
        shouldOverrideUrlLoading: (controller, navigationAction) {
          print("shouldOverrideUrlLoading");
          print(jsonEncode(navigationAction.request.headers));
          return Future.value(NavigationActionPolicy.ALLOW);
        },
      ),
    );
  }

  windowOpen(String url) {
    rootController.evaluateJavascript(
        source:
            "window.open('$url', ${DateTime.now().millisecondsSinceEpoch})");
  }

  closeAllPopups() {
    controllers.forEach((element) {
      if (element != rootController)
        element.evaluateJavascript(source: "window.close();");
    });
  }
}
