import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/view/main_model.dart';
import 'package:luckus7/view/auto_orders_page.dart';
import 'package:luckus7/view/manual_orders_page.dart';
import 'package:luckus7/view/tickets_page.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            child: Column(
              children: [AutoOrdersPage()],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [ManualOrdersPage()],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(),
          ),
        ],
      ),
      floatingActionButton: Obx(() => model.pageIndex.value == 0
          ? FloatingActionButton(
              onPressed: () {},
              tooltip: 'Increment',
              child: Icon(Icons.add),
            )
          : Row()),
    );
  }
}
