import 'dart:math';

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
                      rows: [for (var i = 0; i < 10; i++) i].map((e) {
                        final gameCnt = e + 1;

                        return DataRow(cells: [
                          DataCell(Text(
                            "$gameCnt 줄",
                            style: TextStyle(fontSize: 16),
                          )),
                          cellForPlayCnt(context, status, "mega", gameCnt),
                          cellForPlayCnt(context, status, "power", gameCnt),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              })
        ],
      );

  DataCell cellForPlayCnt(
      BuildContext context, OrderStatus status, String orderName, int playCnt) {
    final gameStatus = orderName == "mega" ? status.mega : status.power;
    final orderCnt = gameStatus.autoOrderCounts[playCnt - 1];

    return DataCell(
        Container(
          color:
              orderCnt.issuedCnt == orderCnt.totalCnt && orderCnt.totalCnt > 0
                  ? Colors.lightBlue[100]
                  : null,
          child: Text(
            "${orderCnt.issuedCnt} / ${orderCnt.totalCnt} 장",
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 16,
                color: orderCnt.totalCnt == 0 ? Colors.grey : null),
          ),
        ), onTap: () {
      final issuedOrders = gameStatus.getIssuedAutoOrdersByPlayCnt(playCnt);
      if (issuedOrders.isEmpty) {
        return;
      }

      print(issuedOrders.map((e) => e.ticketImageUrl).join("\n"));

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            height: 800,
            width: [1400, 400 * issuedOrders.length].reduce(min).toDouble(),
            padding: EdgeInsets.all(10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: issuedOrders
                  .map((e) => e.ticketImageUrl)
                  .map((e) => Image.network(
                        e,
                        width: 400,
                      ))
                  .map((e) => Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: e,
                      ))
                  .toList(),
            ),
          ),
        ),
      );
    });
  }
}
