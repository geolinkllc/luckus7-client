import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.cushion.lucs/model/order.dart';
import 'package:com.cushion.lucs/service/order_service.dart';
import 'package:com.cushion.lucs/service/ticket_print_service.dart';
import 'package:com.cushion.lucs/service/ticket_service.dart';
import 'package:com.cushion.lucs/manager_view/auto_orders_summary_page.dart';
import 'package:com.cushion.lucs/manager_view/tickets_page.dart';
import 'package:com.cushion.lucs/extentions.dart';

import 'manual_orders_page.dart';

class ManagerMainPage extends StatelessWidget {
  // final pref = Get.find<SharedPreferences>();
  final orderService = Get.find<OrderService>();
  final ticketService = Get.find<TicketService>();
  final printService = Get.find<TicketPrintService>();

  @override
  StatelessElement createElement() {
    final elem = super.createElement();
    DesktopWindow.setWindowSize(Size(1920, 1000));
    return elem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: StreamBuilder<String?>(
          stream: ticketService.asyncMessage,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(snapshot.data!),
                  duration: const Duration(seconds: 1),
                ));

                ticketService.asyncMessage.value = null;
              });
            }

            return Container();
          }),
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: StreamBuilder<OrderStatus?>(
            stream: orderService.status,
            builder: (context, snapshot) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (snapshot.data?.date ?? "") +
                        " 발권" +
                        (snapshot.data?.isComplete == true ? " 완료" : ""),
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              );
            }),
        actions: [
          StreamBuilder<OrderStatus?>(
              stream: orderService.status,
              builder: (context, snapshot) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: OutlinedButton(
                      onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Text("메시지를 보내시겠습니까?"),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.grey),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("취소"),
                                ),
                                ElevatedButton(
                                    style:
                                    ElevatedButton.styleFrom(primary: Colors.red),
                                  onPressed: () {
                                    ticketService.sendUploadNoti();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("보내기"),
                                )
                              ],
                            ),
                          ),
                      child: Text(
                        "스캔본 업로드 알림 메시지 발송",
                        style: TextStyle(color: Colors.black54),
                      )),
                );
              }),
          StreamBuilder<String>(
              stream: ticketService.incomingFolder,
              builder: (context, snapshot) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: OutlinedButton(
                      onPressed: () => ticketService.selectIncomingDir(context),
                      child: Text(
                        "스캔폴더변경(${snapshot.data?.lastPathComponent ?? ""})",
                        style: TextStyle(color: Colors.black54),
                      )),
                );
              }),
          StreamBuilder<String>(
              stream: ticketService.driveFolder,
              builder: (context, snapshot) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: OutlinedButton(
                      onPressed: () => ticketService.selectDriveDir(context),
                      child: Text(
                        "구글드라이브폴더변경(${snapshot.data?.lastPathComponent ?? ""})",
                        style: TextStyle(color: Colors.black54),
                      )),
                );
              }),
/*
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: OutlinedButton(
                onPressed: () => printService.printTickets(),
                child: Text(
                  "신청용지인쇄",
                  style: TextStyle(color: Colors.black54),
                )),
          ),
*/
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 400,
            height: double.infinity,
            child: AutoOrdersSummaryPage(),
          ),
          SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 250,
            height: double.infinity,
            child: ManualOrdersSummaryPage(OrderNameMega),
          ),
          SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 250,
            height: double.infinity,
            child: ManualOrdersSummaryPage(OrderNamePower),
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
