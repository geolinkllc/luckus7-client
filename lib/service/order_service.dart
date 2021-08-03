import 'dart:async';

import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:com.cushion.lucs/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:com.cushion.lucs/extentions.dart';

class OrderService extends GetxController {
  // ignore: close_sinks
  final status = BehaviorSubject<OrderStatus?>();

  // ignore: close_sinks
  final message = BehaviorSubject<String?>();

  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    loadOrderStatus();

    resumeUpdate();
  }

  pauseUpdate() {
    timer?.cancel();
  }

  resumeUpdate() {
    const oneSec = const Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer t) => loadOrderStatus());
  }

  loadOrderStatus() async {
    final res = await apicli.get<dynamic>('/orders/status');
    status.value = OrderStatus.fromJson(res.data);
  }

  Future<void> updateOrder(Order order) async {
    try {
      final res = await apicli.post<dynamic>(
          '/order-groups/${order.userName}-${order.time}',
          data: order.toJson());
      final updated = Order.fromJson(res.data);
      status.value = status.value?..updateOrder(updated);
      message.value = "수정했습니다.";
    } on DioError catch (e) {
      message.value = e.responseMessage;
    }
  }

  Future<void> cancelUpload(Order order) async {
    try {
      final res = await apicli.get<dynamic>(
          '/order-groups/${order.userName}-${order.time}/remove-ticket');
      final updated = Order.fromJson(res.data);
      status.value = status.value?..updateOrder(updated);
      message.value = "취소했습니다.";
    } on DioError catch (e) {
      message.value = e.responseMessage;
    }
  }
}
