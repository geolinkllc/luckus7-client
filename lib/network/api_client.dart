import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../flavor.dart';
import '../manager_app.dart';

class ApiClient{
  static Dio create(){
    String apiHost = isDev ? "https://dev.luckus7.com/api" : "https://luckus7.com/api";

    final option = BaseOptions(
      baseUrl: apiHost,
      connectTimeout: 1000 * 60,
      sendTimeout: 1000 * 60,
      receiveTimeout: 1000 * 60,
      contentType: "application/json",
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,
    );

    return Dio(option);
  }
}

get apicli => Get.find<Dio>();