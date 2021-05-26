import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/extentions.dart';
import 'package:luckus7/model/order.dart';
import 'package:luckus7/model/order_status.dart';
import 'package:luckus7/service/order_service.dart';

// ignore: must_be_immutable
class ManualOrdersPage extends StatelessWidget {
  OrderService service = Get.find();

  OrderName orderName;

  ManualOrdersPage(this.orderName);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            height: 52,
            width: double.infinity,
            color: Colors.black12,
            alignment: Alignment.center,
            child: Text(
              "${orderName.name} 수동",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
          ),
          Expanded(
            child: StreamBuilder<OrderStatus?>(
                stream: service.status,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Placeholder(
                      color: Colors.transparent,
                    );
                  }

                  final orders = orderName == OrderNameMega
                      ? snapshot.data!.mega.manualOrders
                      : snapshot.data!.power.manualOrders;

                  return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) =>
                          orderCard(context, orders[index]));
                }),
          )
        ],
      );

  Widget orderCard(BuildContext context, ManualOrder order) => Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
              ),
              Column(
                  children: order.orderNumbers
                      .map((e) => Text(
                            e.numbers,
                            style: TextStyle(fontSize: 18),
                          ))
                      .toList()),
              Visibility(
                visible: order.isIssued,
                child: Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              )
            ],
          ),
        ),
      );
}
