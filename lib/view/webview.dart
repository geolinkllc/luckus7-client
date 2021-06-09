import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

InAppWebView newWebView(BuildContext context) => InAppWebView(
  onCreateWindow: (controller, createWindowRequest) async {

    print("onCreateWindow");

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width,
            height: 400,
            child: InAppWebView(
              initialUrlRequest: createWindowRequest.request,
              // Setting the windowId property is important here!
              windowId: createWindowRequest.windowId,
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  // debuggingEnabled: true,
                ),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                // _webViewPopupController = controller;
              },
              // onLoadStart: (InAppWebViewController controller, String url) {
              //   print("onLoadStart popup $url");
              // },
              // onLoadStop: (InAppWebViewController controller, String url) {
              //   print("onLoadStop popup $url");
              // },
            ),
          ),
        );
      },
    );

    return true;
  },
  initialUrlRequest: URLRequest(url: Uri.parse("https://luckus7.com")),
  // initialHeaders: {},
  initialOptions: InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      supportZoom: false,
      javaScriptCanOpenWindowsAutomatically: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsAirPlayForMediaPlayback: false,
      allowsBackForwardNavigationGestures: false,
      allowsInlineMediaPlayback: true,
      sharedCookiesEnabled: true,
    ),
    android: AndroidInAppWebViewOptions(
      builtInZoomControls: false,
      useHybridComposition: true,
      supportMultipleWindows: true,
    ),
  ),
  onWebViewCreated: (controller) {
    debugPrint('onWebViewCreated');
  },
  onLoadStart: (controller, uri) async {
    debugPrint('onLoadStart: ${uri.toString()}');
    // _model.busy();

    // if (CommonUtils.isChangeUrl(_url, url)) {
    //   _firebaseAnalyticsService.logChangeUrl(url);
    // }

    if (uri?.isScheme('https') == true ||
        uri?.isScheme('http') == true) {
      // 여기서 할 건 없다.
    } else if (Platform.isAndroid && uri?.isScheme('intent') == true) {
      // 직접 인텐트를 처리하므로 로딩은 멈춘다.
      await controller.stopLoading();

      final fragment = uri!.fragment;
      final package = RegExp(r'package=([A-Za-z0-9_.]+);')
          .firstMatch(fragment)
          ?.group(1);
      final scheme = RegExp(r'scheme=([a-z][a-z0-9+\-.]*);')
          .firstMatch(fragment)
          ?.group(1);
      if (package?.isNotEmpty == true && scheme?.isNotEmpty == true) {
        String url = Uri.decodeFull(
            uri.removeFragment().replace(scheme: scheme).toString());
        if (await canLaunch(url)) {
          AndroidIntent intent = AndroidIntent(
            action: 'action_view',
            data: Uri.encodeFull(url),
            package: package,
          );
          intent.launch();
        } else {
          // scheme에 맞는 앱이 설치되지 않은 경우다.
          final fallbackUrl =
          RegExp(r'S.browser_fallback_url=([\w#!:.?+=&%@!\-\/]*);')
              .firstMatch(fragment)
              ?.group(1);
          if (fallbackUrl?.isNotEmpty == true) {
            url = Uri.decodeFull(fallbackUrl!);
          } else {
            final marketReferrer =
            RegExp(r'S.market_referrer=([\w#!:.?+=&%@!\-\/]*);')
                .firstMatch(fragment)
                ?.group(1);
            final referrer = marketReferrer != null
                ? '&referrer=$marketReferrer'
                : '';
            url = 'market://details?id=$package$referrer';
          }
          debugPrint('fallback URL: $url');
          // 마켓으로 연결되므로 그냥 연다.
          await launch(url);
          controller.goBack();
        }
      }
    } else {
      if (await canLaunch(uri.toString())) {
        await launch(uri.toString());
      } else {
        debugPrint(
            "(TRACE) Couldn't open link. Go back to origin link.");
        controller.goBack();
      }
    }
  },
  onLoadStop: (controller, url) {
    debugPrint('onLoadStop: $url');
    // _model.idle();
  },
  onLoadError: (controller, uri, code, message) async {
    debugPrint('onLoadError: ($code) $message ${uri.toString()}');
    // _model.idle();

    if (uri?.isScheme('https') != true &&
        uri?.isScheme('http') != true &&
        await canLaunch(uri.toString())) {
      // Redirection to URL with a scheme that is not HTTP(S)
      await launch(uri.toString());
    } else if (await canLaunch(uri.toString())) {
      // unsupported URL
      // redirect로 다른 동작(딥 링킹)을 하는 경우로 추정. 외부 브라우저를 사용하자.
      await launch(
        uri.toString(),
        forceSafariVC: false,
      );
    }
  },
  onProgressChanged: (controller, progress) async {
    debugPrint('onProgressChanged: $progress');
    // if (progress == 100) _model.idle();
  },
  onConsoleMessage: (controller, consoleMessage) {
    debugPrint('onConsoleMessage: ${consoleMessage.message}');
  },
);