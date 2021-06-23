import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.luckus7.lucs/model/order.dart';
import 'package:com.luckus7.lucs/model/order.dart';
import 'package:com.luckus7.lucs/model/ticket.dart';
import 'package:com.luckus7.lucs/service/ticket_service.dart';

// ignore: must_be_immutable
class TicketsPage extends StatelessWidget {
  TicketService service = Get.find();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Ticket>>(
      stream: service.tickets,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 800),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              runAlignment: WrapAlignment.start,
              alignment: WrapAlignment.start,
              verticalDirection: VerticalDirection.down,
              children:
                  (snapshot.data ?? []).map((e) => ticketView(e)).toList(),
            ),
          ),
        );
      });

  Widget ticketView(Ticket t) {
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
}
