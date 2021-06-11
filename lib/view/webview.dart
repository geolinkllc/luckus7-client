import 'dart:convert';

import 'package:com.luckus7.lucs/service/messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
      {URLRequest? initialUrlRequest, CreateWindowAction? createWindowAction}) {
    InAppWebViewController? _controller;

    return WillPopScope(
      onWillPop: () async {
        if (_controller == null) {
          return true;
        }

        final canGoBack = await _controller!.canGoBack();

        _controller?.goBack();

        debugPrint("onWillPop.canGoBack = $canGoBack");

        return !canGoBack;
      },
      child: InAppWebView(
        windowId: createWindowAction?.windowId,
        onCreateWindow: (controller, createWindowRequest) async {
          print("onCreateWindow");

          await showCupertinoModalBottomSheet(
            context: context,
            builder: (context) =>
                newWebView(context, createWindowAction: createWindowRequest),
          );

          return true;
        },
        initialUrlRequest: createWindowAction != null
            ? createWindowAction.request
            : initialUrlRequest,
        // initialHeaders: {},
        initialOptions: _initialOptions,
        onWebViewCreated: (controller) {
          controllers.add(controller);
          _controller = controller;
        },
        onLoadStop: onLoadStop,
        onLoadError: onLoadError,
        onProgressChanged: onProgressChanged,
        onConsoleMessage: onConsoleMessage,
        onCloseWindow: (controller) {
          controllers.remove(controller);
        },
        onLoadStart: (controller, url) {
          print("onLoadStart");
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
}
