import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.cushion.lucs/model/order.dart';
import 'package:com.cushion.lucs/model/order.dart';
import 'package:com.cushion.lucs/model/ticket.dart';
import 'package:com.cushion.lucs/service/ticket_service.dart';

// ignore: must_be_immutable
class TicketsPage extends StatelessWidget {
  TicketService service = Get.find();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Ticket>>(
      stream: service.tickets,
      builder: (context, snapshot) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            StreamBuilder<OrderType>(
              stream: service.orderType,
              builder: (context, orderTypeSnap) => StreamBuilder<OrderName>(
                  stream: service.orderName,
                  builder: (context, orderNameSnap) {
                    return Container(
                      height: 52,
                      width: double.infinity,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "업로드",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(
                            width: 48,
                          ),
                          Radio(
                            value: OrderNameMega,
                            groupValue: orderNameSnap.data,
                            onChanged: (value) {
                              service.orderName.value = OrderNameMega;
                            },
                          ),
                          Text("메가", style: TextStyle(fontSize: 18)),
                          SizedBox(
                            width: 4,
                          ),
                          Radio(
                            value: OrderNamePower,
                            groupValue: orderNameSnap.data,
                            onChanged: (value) {
                              service.orderName.value = OrderNamePower;
                            },
                          ),
                          Text("파워", style: TextStyle(fontSize: 18)),
                          SizedBox(
                            width: 48,
                          ),
                          Radio(
                            value: OrderTypeAuto,
                            groupValue: orderTypeSnap.data,
                            onChanged: (value) {
                              service.orderType.value = OrderTypeAuto;
                            },
                          ),
                          Text("자동", style: TextStyle(fontSize: 18)),
                          SizedBox(
                            width: 4,
                          ),
                          Radio(
                            value: OrderTypeManual,
                            groupValue: orderTypeSnap.data,
                            onChanged: (value) {
                              service.orderType.value = OrderTypeManual;
                            },
                          ),
                          Text("수동", style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    );
                  }),
            ),
            SingleChildScrollView(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.start,
                alignment: WrapAlignment.start,
                verticalDirection: VerticalDirection.down,
                children: (snapshot.data ?? [])
                    .map((e) => ticketView(context, e))
                    .toList(),
              ),
            ),
          ],
        );
      });

  Widget ticketView(BuildContext context, Ticket t) {
    return Card(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.loose,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(
                File(t.filePath),
                width: 300,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      t.process.text,
                      style: TextStyle(
                          fontSize: 18,
                          color: t.process == TicketProcessProcessing
                              ? Colors.blue
                              : Colors.red),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Visibility(
                      visible: t.process != TicketProcessProcessing,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio(
                                value: OrderNameMega,
                                groupValue: t.orderName,
                                onChanged: (value) {
                                  service.modify(t..orderName = OrderNameMega);
                                },
                              ),
                              Text("메가", style: TextStyle(fontSize: 18)),
                              Radio(
                                value: OrderNamePower,
                                groupValue: t.orderName,
                                onChanged: (value) {
                                  service.modify(t..orderName = OrderNamePower);
                                },
                              ),
                              Text("파워볼", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
/*
                          Container(
                            width: 270,
                            child: TextField(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                                controller: t.drawNumberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  suffix: Text("회"),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelText: "회차")),
                          ),
*/
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            width: 270,
                            child: TextField(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                wordSpacing: 10,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: 16, right: 16, top: 16, bottom: 8),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  labelText: "번호"),
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 10,
                              controller: t.numbersController,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 130,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          service.post(t);
                                        },
                                        child: Text("재시도")),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        service.delete(t);
                                      },
                                      child: Text("삭제"),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height:4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 130,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.grey),
                                        onPressed: () {
                                          service.extraOrderUserIdController.text = "01082120017";
                                          service.registerExtraOrder(t);
                                        },
                                        child: Text("회사잔여분할당")),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.grey),
                                        onPressed: () {
                                          showCreateExtraOrderDialog(context, t);
                                        },
                                        child: Text("여분주문생성")),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Visibility(
            visible: t.process == TicketProcessProcessing,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }

  showCreateExtraOrderDialog(BuildContext context, Ticket t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("잔여복권 주문등록"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("잔여복권을 할당할 회원 아이디를 입력하세요"),
            SizedBox(height:16),
            TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
              ),
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: "회원 아이디"),
              keyboardType: TextInputType.phone,
              controller: service.extraOrderUserIdController,
            )
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("취소"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.blue),
            onPressed: () {
              if(service.registerExtraOrder( t))
                Navigator.of(context).pop();
            },
            child: Text("등록"),
          ),
        ],
      ),
    );
  }
}
