import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/model/order.dart';
import 'package:luckus7/service/order_service.dart';
import 'package:luckus7/service/ticket_service.dart';
import 'package:luckus7/view/auto_orders_page.dart';
import 'package:luckus7/view/tickets_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manual_orders_page.dart';

class MainPage extends StatelessWidget {
  // final pref = Get.find<SharedPreferences>();
  final orderService = Get.find<OrderService>();
  final ticketService = Get.find<TicketService>();

  @override
  StatelessElement createElement() {
    final elem = super.createElement();
    DesktopWindow.setWindowSize(Size(1920, 1000));
    return elem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.refresh_rounded),
          onPressed: () => orderService.loadOrderStatus(forceRefresh: true),
        ),
        elevation: 1,
      centerTitle: true,
      title: Text("LUCS", style: TextStyle(fontSize: 24), ),
        actions: [
          StreamBuilder<String>(
              stream: ticketService.incomingFolder,
              builder: (context, snapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.data ?? "", style: TextStyle(fontSize: 20),),
                  ],
                );
              }),
          SizedBox(width: 8,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: OutlinedButton(
                onPressed: () => ticketService.selectIncomingDir(context),
                child: Text(
                  "스캔폴더변경",
                  style: TextStyle(color: Colors.black54),
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: OutlinedButton(
                onPressed: () => orderService.printManualOMR(),
                child: Text(
                  "수동주문인쇄",
                  style: TextStyle(color: Colors.black54),
                )),
          ),
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
            width: 250,
            height: double.infinity,
            child: ManualOrdersPage(OrderNameMega),
          ),
          SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 250,
            height: double.infinity,
            child: ManualOrdersPage(OrderNamePower),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            flex: 3,
            child: TicketsPage(),
          ),
        ],
      ),
    );
  }
}
