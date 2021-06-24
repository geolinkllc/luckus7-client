import 'package:com.cushion.lucs/service/messaging_service.dart';
import 'package:com.cushion.lucs/view/webview_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../user_app.dart';
import 'user_main_model.dart';

class UserMainPage extends StatelessWidget {
  UserMainModel model = Get.find();
  MessagingService messagingService = Get.find();
  WebViewController webViewController = Get.find();
  PackageInfo packageInfo = Get.find();

  @override
  Widget build(BuildContext context) {
    var initialUrl =
        flavor == "dev" ? "https://dev.luckus7.com" : "https://luckus7.com";

    // initialUrl = "https://dev.luckus7.com/theme/basic/mobile/ticket.php?img=/img/lottery/img_2_11971624321401.jpg";
    // initialUrl = "https://dev.luckus7.com/theme/basic/mobile/ticket.php?img=%2Fimg%2Flottery%2Fimg_2_11971624321401.jpg";

    return Scaffold(
      body: Stack(
        children: [
          messageHandler(),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              progressBar(),
              Expanded(
                child: webViewController.createWebView(context,
                    initialUrlRequest:
                        URLRequest(url: Uri.parse(initialUrl))),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget progressBar() => StreamBuilder<int>(
        stream: webViewController.progress,
        builder: (context, snapshot) => AnimatedOpacity(
          opacity: snapshot.data == 100 || snapshot.data == 0 ? 0 : 1,
          duration: Duration(milliseconds: 200),
          child: FAProgressBar(
            size: MediaQuery.of(context).padding.top,
            backgroundColor: Colors.white,
            progressColor: Colors.blueAccent,
            borderRadius: BorderRadius.zero,
            currentValue: snapshot.data ?? 0,
          ),
        ),
      );

  Widget messageHandler() => StreamBuilder<dynamic>(
      stream: messagingService.asyncMessageStraem,
      builder: (context, snapshot) {
        final data = snapshot.data;

        if (data == null) {
          return Container();
        }

        if (data is RemoteMessage) {
          if (data.data.containsKey("in-link") == true) {
            final link = data.data["in-link"];
            webViewController.windowOpen(link);
          }
        } else if (data is JsAlertRequest) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(data.message ?? ""),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("확인"))
              ],
            ),
          );
        }

        return Container();
      });
}
