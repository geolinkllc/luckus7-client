import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtention on DateTime {
  String format(String layout){
    return DateFormat(layout).format(this);
  }
}

extension ContextExtention on BuildContext {
  ThemeData theme(){
    return Theme.of(this);
  }
}

const cmpt = 28.5;

extension DoubleExtention on double {
  double get cm => this * cmpt;
}

extension IntExtention on int {
  double get cm => this * cmpt;
}
