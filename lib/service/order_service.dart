import 'dart:async';

import 'package:com.luckus7.lucs/model/order_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrderService extends GetxController {
  // ignore: close_sinks
  final status = BehaviorSubject<OrderStatus?>();

  @override
  void onInit() {
    super.onInit();
    loadOrderStatus();
  }

  loadOrderStatus({forceRefresh = false}) async {
    if (forceRefresh) status.value = null;

    final res =
        await Dio().get<dynamic>('http://52.79.208.66:8080/orders/status');
    status.value = OrderStatus.fromJson(res.data);
  }
}
