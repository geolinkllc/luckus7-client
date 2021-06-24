import 'dart:async';

import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:com.cushion.lucs/network/api_client.dart';
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
        await apicli.get<dynamic>('/orders/status');
    status.value = OrderStatus.fromJson(res.data);
  }
}
