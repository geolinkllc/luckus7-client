import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../manager_app.dart';

class ApiClient{
  static Dio create(){
    final option = BaseOptions(
      baseUrl: "http://52.79.208.66:8080",
      connectTimeout: 1000 * 60,
      sendTimeout: 1000 * 60,
      receiveTimeout: 1000 * 60,
      contentType: "application/json",
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,
    );

    if(flavor == "dev") {
      option.baseUrl = "http://54.180.87.129:8080";
    }

    return Dio(option);
  }
}

get apicli => Get.find<Dio>();