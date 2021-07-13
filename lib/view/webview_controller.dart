import 'dart:convert';
import 'dart:io';

import 'package:com.cushion.lucs/service/messaging_service.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';

class WebViewController extends GetxController {
  PackageInfo packageInfo = Get.find();
  MessagingService messagingService = Get.find();
  final cookieManager = CookieManager.instance();

  late InAppWebViewGroupOptions _initialOptions;
  final controllers = <InAppWebViewController>[];

  // ignore: close_sinks
  final progress = BehaviorSubject<int>.seeded(0);

  InAppWebViewController get rootController => controllers.first;

  InAppWebViewController get currentController => controllers.last;

  WebViewController() {
    _initialOptions = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        transparentBackground: false,
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
        allowsBackForwardNavigationGestures: true,
        allowsInlineMediaPlayback: true,
        sharedCookiesEnabled: false,
      ),
      android: AndroidInAppWebViewOptions(
        builtInZoomControls: false,
        useHybridComposition: false,
        supportMultipleWindows: true,
        domStorageEnabled: true,
        mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        loadsImagesAutomatically: true,
        blockNetworkImage: false,
        blockNetworkLoads: false,
        appCachePath: "",
        thirdPartyCookiesEnabled: true,
        defaultTextEncodingName: "UTF-8",
        allowFileAccess: true,
        databaseEnabled: true,
        allowContentAccess: true,
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
      InAppWebViewController controller, Uri? url, int code, String message) {
    print("onLoadError: " + (url?.toString() ?? "") + " : " + message);
  }

  onLoadStop(InAppWebViewController controller, Uri? url) async {
    // print("onLoadStop: " + (url?.toString() ?? ""));
  }

  Future<bool> onWillPop() async {
    final canGoBack = await currentController.canGoBack();

    if (canGoBack) {
      currentController.goBack();
      return false;
    } else {
      if (currentController == rootController) {
        return true;
      } else {
        currentController.evaluateJavascript(source: "window.close()");
        return false;
      }
    }
  }

  Widget _createWebView(BuildContext context,
      {URLRequest? initialUrlRequest,
      CreateWindowAction? createWindowAction,
      List<Cookie> cookies = const []}) {

    final req = createWindowAction != null
        ? createWindowAction.request
        : initialUrlRequest;


    return InAppWebView(
      key: UniqueKey(),
      // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[Factory(() => EagerGestureRecognizer())].toSet(),
      windowId: createWindowAction?.windowId,
      initialUrlRequest: req,
      // initialHeaders: {},
      initialOptions: _initialOptions,
      onWebViewCreated: (controller) {
        controllers.add(controller);
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
          print(url);
        showModalBottomSheet(
          elevation: 8,
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * (1 - controllers.length * 0.05),
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: createWebView(context,
                    createWindowAction: createWindowRequest)),
          ),
        );
        return true;
      },
      onCloseWindow: (controller) {
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
    );
  }

  Widget createWebView(BuildContext context,
      {URLRequest? initialUrlRequest,
      CreateWindowAction? createWindowAction,
      List<Cookie> cookies = const []}) {

    final webview = _createWebView(context,
        initialUrlRequest: initialUrlRequest,
        createWindowAction: createWindowAction,
        cookies: cookies);

    if( Platform.isAndroid) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: webview,
      );
    } else {
      return webview;
    }
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
