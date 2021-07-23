import 'dart:io';

import 'package:com.cushion.lucs/model/app_version.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';
import 'package:com.cushion.lucs/extentions.dart';

import '../flavor.dart';
import '../user_app.dart';

class UserMainModel extends GetxController {
  Dio dio = Get.find();
  PackageInfo packageInfo = Get.find();
  String get webHost => isDev ? "http://dev.luckus7.com" : "https://luckus7.com";
  final apiResponseStream = BehaviorSubject<dynamic>();


  Future<void> checkVersion() async {
    String os = Platform.isAndroid ? "aos" : "ios";

    final res =
        await dio.get<dynamic>('/app-version/$os');

    final version = AppVersion.fromMap(res.data);

    if( version.buildNumber > packageInfo.buildNumber.numValue && version.releasedAt.isBefore(DateTime.now())) {
      apiResponseStream.value = version;
    }
  }
}
