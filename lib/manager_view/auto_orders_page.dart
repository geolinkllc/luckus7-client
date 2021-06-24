import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.cushion.lucs/extentions.dart';
import 'package:com.cushion.lucs/model/order.dart';
import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:com.cushion.lucs/service/order_service.dart';

// ignore: must_be_immutable
class AutoOrdersPage extends StatelessWidget {
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
              "자동",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
          ),
          StreamBuilder<OrderStatus?>(
              stream: service.status,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Placeholder(
                    color: Colors.transparent,
                  );
                }

                final status = snapshot.data!;

                return Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: [
                        DataColumn(
                            label: Text(
                          "줄수",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16),
                        )),
                        DataColumn(
                            label: Text(
                          "메가",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16),
                        )),
                        DataColumn(
                            label: Text(
                          "파워볼",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16),
                        )),
                      ],
                      rows: [for (var i = 0; i < 10; i += 1) i].map((e) {
                        final gameCnt = e + 1;
                        final megaOrders = status.mega.autoOrderCounts[e];
                        final powerOrders = status.power.autoOrderCounts[e];

                        return DataRow(cells: [
                          DataCell(Text(
                            "$gameCnt 줄",
                            style: TextStyle(fontSize: 16),
                          )),
                          DataCell(Container(
                            color: megaOrders.issuedCnt == megaOrders.totalCnt && megaOrders.totalCnt > 0 ? Colors.lightBlue[100] : null,
                            child: Text(
                              "${megaOrders.issuedCnt} / ${megaOrders.totalCnt} 장",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 16, color: megaOrders.totalCnt == 0 ? Colors.grey : null),
                            ),
                          )),
                          DataCell(Container(
                            color: powerOrders.issuedCnt == powerOrders.totalCnt && powerOrders.totalCnt > 0 ? Colors.lightBlue[100] : null,
                            child: Text(
                                "${powerOrders.issuedCnt} / ${powerOrders.totalCnt} 장",
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 16, color: powerOrders.totalCnt == 0 ? Colors.grey : null)),
                          )),
                        ]);
                      }).toList(),
                      /*rows: [
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text(
                          "0 / 20 장",
                          textAlign: TextAlign.right,
                        )),
                        DataCell(Text("10 / 30 장", textAlign: TextAlign.center)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text("0 / 20 장", textAlign: TextAlign.center)),
                        DataCell(Text("10 / 30 장", textAlign: TextAlign.center)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text("0 / 20 장", textAlign: TextAlign.center)),
                        DataCell(Text("10 / 30 장", textAlign: TextAlign.center)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text("0 / 20 장", textAlign: TextAlign.center)),
                        DataCell(Text("10 / 30 장", textAlign: TextAlign.center)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text("0 / 20 장")),
                        DataCell(Text("10 / 30 장")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text("0 / 20 장")),
                        DataCell(Text("10 / 30 장")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text("0 / 20 장")),
                        DataCell(Text("10 / 30 장")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text("0 / 20 장")),
                        DataCell(Text("10 / 30 장")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text("0 / 20 장")),
                        DataCell(Text("10 / 30 장")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("1 줄")),
                        DataCell(Text("0 / 20 장")),
                        DataCell(Text("10 / 30 장")),
                      ]),
                    ]*/
                    ),
                  ),
                );
              })
        ],
      );
}
