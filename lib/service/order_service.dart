import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:com.cushion.lucs/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:com.cushion.lucs/extentions.dart';
import 'package:com.cushion.lucs/model/order.dart';

import 'ticket_service.dart';

class OrderService extends GetxController {
  late TicketService ticketService = Get.find();

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

      final newPath = ticketService.driveFolder.value +
          pathDelim +
          DateTime.now().format("yyyy-MM-dd") +
          pathDelim +
          "misread" +
          pathDelim +
          "${order.userName}_${order.time}.jpg";

      GetOrderTicketBackupFile(updated)?.copy(newPath);

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

  File? GetOrderTicketBackupFile(Order order) {
    if (!order.isIssued) {
      return null;
    }

    if (ticketService.driveFolder.value == "") {
      return null;
    }

    final path = ticketService.driveFolder.value +
        pathDelim +
        DateTime.now().format("yyyy-MM-dd") +
        pathDelim +
        "${order.orderName}_${order.orderType.engText}" +
        pathDelim +
        "${order.userName}_${order.time}.jpg";

    return File.fromRawPath(Uint8List.fromList(path.codeUnits));
  }
}
