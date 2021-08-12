import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:com.cushion.lucs/model/ticket.dart';
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

    if (ticketService
        .filesInScanFolder()
        .isNotEmpty) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        showDialog(
          context: elem,
          builder: (context) =>
              AlertDialog(
                content: Text(
                    "스캔폴더에 이미지 ${ticketService
                        .filesInScanFolder()
                        .length} 개가 남아있습니다."),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: () {
                      ticketService.clearScanFolder();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("삭제했습니다."),
                        duration: const Duration(seconds: 1),
                      ));
                      Navigator.of(context).pop();
                    },
                    child: Text("삭제"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                    onPressed: () {
                      ticketService.uploadFilesInScanFolder();
                      Navigator.of(context).pop();
                    },
                    child: Text("업로드"),
                  )
                ],
              ),
        );
      });
    }

    return elem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: StreamBuilder<String?>(
          stream: ticketService.asyncMessages,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(snapshot.data!),
                  duration: const Duration(seconds: 1),
                ));

                ticketService.asyncMessages.value = null;
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
        leadingWidth: 600,
        leading: Row(
          children: [
            StreamBuilder<String>(
                stream: ticketService.scanFolder,
                builder: (context, snapshot) {
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                          onPressed: () =>
                              ticketService.selectIncomingDir(context),
                          child: Text(
                            "스캔폴더변경(${snapshot.data?.lastPathComponent ?? ""})",
                            style: TextStyle(color: Colors.black54),
                          )),
                    ),
                  );
                }),
            StreamBuilder<String>(
                stream: ticketService.driveFolder,
                builder: (context, snapshot) {
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                          onPressed: () =>
                              ticketService.selectDriveDir(context),
                          child: Text(
                            "백업폴더변경(${snapshot.data ?? ""})",
                            style: TextStyle(color: Colors.black54),
                          )),
                    ),
                  );
                }),
          ],
        ),
        actions: [
          StreamBuilder<OrderStatus?>(
              stream: orderService.status,
              builder: (context, snapshot) {
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: OutlinedButton(
                      onPressed: () =>
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
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
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.red),
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
            stream: ticketService.driveFolder,
            builder: (context, drivePathSnap) =>
                StreamBuilder<List<Ticket>>(
                    stream: ticketService.tickets,
                    builder: (context, ticketsSnap) {
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: OutlinedButton(
                            onPressed: () =>
                                openBackupDialog(
                                    context, drivePathSnap, ticketsSnap),
                            child: Text(
                              "잔여티켓백업",
                              style: TextStyle(color: Colors.black54),
                            )),
                      );
                    }),
          ),

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

  openBackupDialog(BuildContext context, AsyncSnapshot<String> drivePathSnap,
      AsyncSnapshot<List<Ticket>> ticketsSnap) {
    if ((drivePathSnap.data ?? "") == "") {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              content: Text(
                  "백업폴더를 선택해주세요"),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("닫기"),
                )
              ],
            ),
      );

      return;
    }

    if ((ticketsSnap.data?.length ?? 0) == 0) {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              content: Text(
                  "잔여티켓이 없습니다."),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("닫기"),
                )
              ],
            ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content: Text(
                "잔여티켓 ${ticketsSnap.data?.length ?? 0}장을 백업폴더로 옮길까요?"),
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
                style: ElevatedButton.styleFrom(
                    primary: Colors.blue),
                onPressed: () {
                  ticketService.backupRemainTickets();
                  Navigator.of(context).pop();
                },
                child: Text("백업하기"),
              )
            ],
          ),
    );
  }
}
