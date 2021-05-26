import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/extentions.dart';
import 'package:luckus7/model/order.dart';
import 'package:luckus7/model/order_status.dart';
import 'package:luckus7/service/order_service.dart';

// ignore: must_be_immutable
class ImageProcessingPage extends StatelessWidget {
  OrderService service = Get.find();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            height: 52,
            width: double.infinity,
            color: Colors.black12,
            alignment: Alignment.center,
            child: Text(
              "처리중인 티켓",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
          ),
          // Expanded(
          // )
        ],
      );
}
