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
