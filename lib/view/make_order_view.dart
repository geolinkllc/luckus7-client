import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luckus7/model/order.dart';
import 'package:luckus7/view/make_order_model.dart';

class MakeOrderView extends StatelessWidget {
  MakeOrderModel model = Get.find();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 400,
        height: double.infinity,
        child: Drawer(
          elevation: 2,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: Text(
                  "주문등록",
                  style: TextStyle(color: Colors.white),
                ),
                decoration: BoxDecoration(color: Colors.lightBlue),
                padding: EdgeInsets.all(16),
              ),
              Obx(() => Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  RadioListTile<OrderSelectionType>(
                                    value: OrderSelectionTypeAuto,
                                    groupValue: model.selectionType.value,
                                    onChanged: model.selectionType,
                                    title: Text("자동"),
                                  ),
                                  RadioListTile<OrderSelectionType>(
                                    value: OrderSelectionTypeManual,
                                    groupValue: model.selectionType.value,
                                    onChanged: model.selectionType,
                                    title: Text("수동"),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 200,
                              height: 100,
                              child: TextField(
                                focusNode: model.amountFocus,
                                controller: model.amountController,
                                // onChanged: model.onAmountChanged,
                                  style: TextStyle(fontSize: 48),
                                  textAlign: TextAlign.right,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    model.amountFilter,
                                  ],
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 32),
                                      suffixStyle: TextStyle(fontSize: 16),
                                      labelStyle: TextStyle(fontSize: 16),
                                      suffixText: "게임",
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      labelText: "수량"),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Stack(alignment: Alignment.center, children: [
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          Container(
                            child: Text("수동"),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          )
                        ]),
                        SizedBox(
                          height: 16,
                        ),
                        TextField(
                            decoration: InputDecoration(
                                suffixText: "부터",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: "시작"),
                            textInputAction: TextInputAction.next),
                        SizedBox(
                          height: 16,
                        ),
                        TextField(
                            decoration: InputDecoration(
                                suffixText: "부터",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: "시작"),
                            textInputAction: TextInputAction.next),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      );
}
