import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/model/order.dart';
import 'package:luckus7/extentions.dart';
import 'package:luckus7/view/make_order_view.dart';
import 'package:luckus7/view/orders_model.dart';

// ignore: must_be_immutable
class OrdersPage extends StatelessWidget {
  OrdersModel model = Get.find();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          ordersList(context),
        ],
      );

  Widget ordersList(BuildContext context) => StreamBuilder<Iterable<Order>>(
      stream: model.orders,
      builder: (context, snapshot) => Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisExtent: 100,
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) =>
                  orderCard(context, snapshot.data!.elementAt(index)),
            ),
          ));

  Widget orderCard(BuildContext context, Order order) => Card(
        child: Column(
          children: [
            Text(order.orderedAt.format('yyyy-MM-dd')),
            Text("자동 ${order.autoCnt}"),
            Text("수동 ${order.manualNumbers.length}"),
            ListView.builder(
                shrinkWrap: true,
                itemCount: order.manualNumbers.length,
                itemBuilder: (context, index) =>
                    Text(order.manualNumbers[index].str))
          ],
        ),
      );

}
