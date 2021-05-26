import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/model/order.dart';
import 'package:luckus7/view/auto_orders_page.dart';
import 'package:luckus7/view/image_processing_page.dart';
import 'package:luckus7/view/main_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manual_orders_page.dart';

class MainPage extends StatelessWidget {
  final pref = Get.find<SharedPreferences>();
  final model = Get.find<MainModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(model.incomingFolder.value)),
        actions: [
          IconButton(
              onPressed: () => model.selectIncomingDir(context),
              icon: Icon(Icons.open_in_browser_rounded))
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: AutoOrdersPage(),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            flex: 1,
            child: ManualOrdersPage(OrderNameMega),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            flex: 1,
            child: ManualOrdersPage(OrderNamePower),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            flex: 1,
            child: ImageProcessingPage(),
          ),
        ],
      ),
    );
  }
}
