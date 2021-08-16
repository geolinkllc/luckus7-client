import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtention on DateTime {
  String format(String layout) {
    return DateFormat(layout).format(this);
  }
}

// extension ContextExtention on BuildContext {
//   ThemeData theme(){
//     return Theme.of(this);
//   }
// }

const cmpt = 28.5;

extension DoubleExtention on double {
  double get cm => this * cmpt;
}

extension IntExtention on int {
  double get cm => this * cmpt;
}

extension StringExtention on String {
  num get numValue {
    return num.tryParse(this.trim().replaceAll(",", "")) ?? 0;
  }

  String get lastPathComponent => this.split("/").last;
}

extension DioErrorExt on DioError {
  String get responseMessage {
    if (response != null) {
      if (response!.data != null &&
          response!.data is Map &&
          response!.data!["message"] != null) {
        return response!.data!["message"];
      } else if (response!.statusMessage != null) {
        return response!.statusMessage!;
      }
    }
    switch (this.type) {

      /// It occurs when url is opened timeout.
      case DioErrorType.connectTimeout:
        return "연결 제한시간이 초과됐습니다";

      /// It occurs when url is sent timeout.
      case DioErrorType.sendTimeout:
        return "데이터 전송 제한시간이 초과됐습니다";

      ///It occurs when receiving timeout.
      case DioErrorType.receiveTimeout:
        return "데이터 수신 제한시간이 초과됐습니다";

      /// When the server response, but with a incorrect status, such as 404, 503...
      case DioErrorType.response:
        return "오류가 발생했습니다: $message";

      /// When the request is cancelled, dio will throw a error with this type.
      case DioErrorType.cancel:
        return "요청이 취소됐습니다";

      /// Default error type, Some other Error. In this case, you can
      /// use the DioError.error if it is not null.
      case DioErrorType.other:
        return "오류가 발생했습니다: $message";
    }
  }
}

String get pathDelim => Platform.isWindows ? "\\" : "/";