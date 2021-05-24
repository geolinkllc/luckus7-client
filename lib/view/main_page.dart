import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/view/main_model.dart';
import 'package:luckus7/view/orders_page.dart';
import 'package:luckus7/view/tickets_page.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatelessWidget {
  final model = Get.find<MainModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("luckus7"),
      // ),
      body: Row(
        children: [
          Drawer(
            elevation: 4,
            child: ListView(padding: EdgeInsets.zero, children: [
              DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "luckus7",
                        style: TextStyle(color: Colors.white),
                      ),
                      ElevatedButton(onPressed: () => model.selectIncomingDir(context), child: Text("스캔폴더선택"))
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                  )),
              ListTile(
                  title: Text("주문목록"),
                  onTap: () {
                    model.pageIndex.value = 0;
                  }),
              ListTile(
                title: Text("처리중인복권"),
                onTap: () {
                  model.pageIndex.value = 1;
                },
                trailing: Chip(
                  label: Text("0"),
                ),
              ),
            ]),
          ),
          Expanded(
            child: Obx(() => IndexedStack(
                  index: model.pageIndex.value,
                  children: model.pages,
                )),
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
