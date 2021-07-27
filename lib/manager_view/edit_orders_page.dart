import 'dart:ui';

import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:com.cushion.lucs/service/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:com.cushion.lucs/model/order.dart';
import 'package:com.cushion.lucs/model/order_status.dart';

class EditOrdersPage extends StatelessWidget {
  OrderService service = Get.find();
  OrderName orderName;
  OrderType orderType;
  int autoCnt;

  EditOrdersPage(this.orderName, this.orderType, {this.autoCnt = 0}) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: StreamBuilder<String?>(
            stream: service.message,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(snapshot.data!),
                    duration: const Duration(seconds: 1),
                  ));

                  service.message.value = null;
                });
              }

              return Container();
            }),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 1,
          centerTitle: true,
          title: Text(
            "${orderName.name} ${orderType.text} ${autoCnt > 0 ? autoCnt.toString() + '줄' : ""}",
            style: TextStyle(fontSize: 24),
          ),
        ),
        body: StreamBuilder<OrderStatus?>(
            stream: service.status,
            builder: (context, snapshot) {
              return SingleChildScrollView(
                child: Stack(
                  fit: StackFit.loose,
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 800),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        runAlignment: WrapAlignment.start,
                        alignment: WrapAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        children: (snapshot.data?.getIssuedOrders(
                                    orderName, orderType, autoCnt) ??
                                [])
                            .map((e) => orderView(e))
                            .toList(),
                      ),
                    ),
                    Visibility(
                        visible: snapshot.data
                                ?.getIssuedOrders(orderName, orderType, autoCnt)
                                .length ==
                            0,
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            "주문이 없습니다",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24),
                          ),
                        ))
                  ],
                ),
              );
            }),
      );

  Widget orderView(Order order) {
    return Card(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.loose,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                order.ticketImageUrl,
                width: 300,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 270,
                          child: Column(
                            children: order.orderNumbers
                                .map((number) => TextField(
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        wordSpacing: 10,
                                        fontFeatures: [
                                          FontFeature.tabularFigures()
                                        ],
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 16,
                                            bottom: 8),
                                      ),
                                      keyboardType: TextInputType.number,
                                      controller: number.numbersController,
                                    ))
                                .toList(),
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
                                    service.updateOrder(order);
                                  },
                                  child: Text("수정")),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            SizedBox(
                              width: 130,
                              child: ElevatedButton(
                                onPressed: () {
                                  service.cancelUpload(order);
                                },
                                child: Text("업로드취소"),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
