import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:luckus7/model/order_status.dart';
import 'package:rxdart/rxdart.dart';

class OrderService extends GetxController {
  // ignore: close_sinks
  final status = BehaviorSubject<OrderStatus?>();

  @override
  void onInit() {
    super.onInit();
    loadOrderStatus();
  }

  loadOrderStatus({forceRefresh = false}) async {
    if( forceRefresh )
      status.value = null;

    final res = await Dio().get<dynamic>('http://34.134.22.192:8080/orders/status');
    status.value = OrderStatus.fromJson(res.data);
  }
}
