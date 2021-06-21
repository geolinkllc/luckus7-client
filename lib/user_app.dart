import 'dart:io';

import 'package:com.luckus7.lucs/service/messaging_service.dart';
import 'package:com.luckus7.lucs/user_view/user_main_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_view/user_main_page.dart';
import 'view/webview_controller.dart';

const flavor = String.fromEnvironment('flavor', defaultValue: 'prod');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await FkUserAgent.init();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  Get.put(await PackageInfo.fromPlatform(), permanent: true);
  Get.put(await SharedPreferences.getInstance(), permanent: true);
  Get.put(MessagingService(), permanent: true);
  await Get.find<MessagingService>().initToken();

  Get.put(WebViewController(), permanent: true);
  Get.put(UserMainModel(), permanent: true);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent, // Color for Android
      statusBarBrightness:
          Brightness.light // Dark == white status bar -- for IOS.
      ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: 'LUCS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                primary: Colors.blue, backgroundColor: Colors.white),
          ),
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(left: 12, right: 8),
            border: OutlineInputBorder(),
            // enabledBorder: OutlineInputBorder(
            //     borderSide: BorderSide(color:Theme.of(context).dividerColor)),
          )),
      home: flavor == "dev"
          ? Banner(
              message: "dev",
              location: BannerLocation.topStart,
              child: UserMainPage())
          : UserMainPage(),
    );
  }
}
