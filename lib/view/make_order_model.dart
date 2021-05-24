import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luckus7/model/order.dart';

class MakeOrderModel extends GetxController {
  final selectionType = OrderSelectionTypeAuto.obs;
  final amountFocus = FocusNode();
  final amountController =
      TextEditingController.fromValue(TextEditingValue(text: "1"));
  final amountFilter = TextInputFormatter.withFunction((oldValue, newValue) {
    print(newValue.text);
    String strVal = newValue.text;

    if (strVal.isBlank ?? true) {
      return newValue.copyWith(text: "1");
    }

    strVal = strVal[newValue.selection.baseOffset-1];
    if( strVal == "0") {
      strVal = "10";
    }

    return newValue.copyWith(text: strVal);
  });

  @override
  void onInit() {

    super.onInit();
  }

  void onChangeModelSelectionType(OrderSelectionType value) {}

  void onAmountChanged(String value) {
    if (value.isNum) {
      int val = int.parse(value);
      if (val < 1) val = 1;
      if (val > 10) val = 10;

      amountController.text = val.toString();
    }
  }
}
