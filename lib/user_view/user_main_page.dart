import 'package:com.luckus7.lucs/service/messaging_service.dart';
import 'package:com.luckus7.lucs/user_view/user_main_model.dart';
import 'package:com.luckus7.lucs/view/webview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info/package_info.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class UserMainPage extends StatelessWidget {
  UserMainModel model = Get.find();
  MessagingService messagingService = Get.find();
  WebViewController webViewController = Get.find();
  PackageInfo packageInfo = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<RemoteMessage>(
              stream: messagingService.messageStream,
              builder: (context, snapshot) {
                if (snapshot.data?.data.containsKey("in-link") == true) {
                  final link = snapshot.data!.data["in-link"];
                  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => webViewController.newWebView(
                          context,
                          initialUrlRequest: URLRequest(url: Uri.parse(link))),
                    );
                  });
                }

                return Container();
              }),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              StreamBuilder<int>(
                  stream: webViewController.progress,
                  builder: (context, snapshot) => AnimatedOpacity(
                    opacity: snapshot.data == 100 || snapshot.data == 0 ? 0 : 1,
                    duration: Duration(milliseconds: 200),
                    child: FAProgressBar(
                      size: MediaQuery.of(context).padding.top,
                      progressColor: Colors.blueAccent,
                        borderRadius: BorderRadius.zero,
                        currentValue: snapshot.data ?? 0,
                      ),
                  ),),
              Expanded(
                child: webViewController.newWebView(context,
                    initialUrlRequest:
                        URLRequest(url: Uri.parse("https://luckus7.com"))),
              ),
            ],
          )
        ],
      ),
    );
  }
}
