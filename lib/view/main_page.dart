import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/model/order.dart';
import 'package:luckus7/service/order_service.dart';
import 'package:luckus7/service/scan_service.dart';
import 'package:luckus7/view/auto_orders_page.dart';
import 'package:luckus7/view/image_processing_page.dart';
import 'package:luckus7/view/main_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manual_orders_page.dart';

class MainPage extends StatelessWidget {
  // final pref = Get.find<SharedPreferences>();
  final model = Get.find<MainModel>();
  final orderService = Get.find<OrderService>();
  final scanService = Get.find<ScanService>();

  @override
  StatelessElement createElement() {
    DesktopWindow.setWindowSize(Size(1920, 1080));
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: StreamBuilder<String>(
          stream: scanService.incomingFolder,
          builder: (context, snapshot) {
            return Text(snapshot.data??"");
          }
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: OutlinedButton(
                onPressed: () => scanService.selectIncomingDir(context),
                child: Text(
                  "스캔폴더변경",
                  style: TextStyle(color: Colors.black54),
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: OutlinedButton(
                onPressed: () => orderService.loadOrderStatus(forceRefresh: true),
                child: Text(
                  "새로고침",
                  style: TextStyle(color: Colors.black54),
                )),
          )
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 400,
            height: double.infinity,
            child: AutoOrdersPage(),
          ),
          SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 230,
            height: double.infinity,
            child: ManualOrdersPage(OrderNameMega),
          ),
          SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 230,
            height: double.infinity,
            child: ManualOrdersPage(OrderNamePower),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            flex: 3,
            child: ImageProcessingPage(),
          ),
        ],
      ),
    );
  }
}
