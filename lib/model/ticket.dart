import 'package:flutter/cupertino.dart';

import 'order.dart';

typedef TicketProcess = String;

const TicketProcessProcessing = "processing";
const TicketProcessMatched = "matched";
const TicketProcessReadFailed = "readFailed";
const TicketProcessReadError = "readError";
const TicketProcessMatchFailed = "matchFailed";
const TicketProcessAssignError = "assignError";

extension TicketProcessExtention on TicketProcess {
  String get text {
    switch (this) {
      case TicketProcessProcessing:
        return "처리중";
      case TicketProcessMatched:
        return "발급완료";
      case TicketProcessReadFailed:
        return "인식실패";
      case TicketProcessReadError:
        return "인식오류";
      case TicketProcessMatchFailed:
        return "주문매칭실패";
      case TicketProcessAssignError:
        return "주문매칭오류";
      default:
        return "";
    }
  }
}

class Ticket {
  String filePath;
  OrderName? orderName;
  String? qrCode;
  String? barCode;
  TicketProcess process = TicketProcessProcessing;
  String? numbers;
  TextEditingController controller;

  Ticket(this.filePath,
      {this.orderName,
      this.qrCode,
      this.barCode,
      this.numbers,
      this.process = TicketProcessProcessing})
      : controller = TextEditingController(text: numbers);

  Ticket.fromJson(dynamic json)
      : filePath = json["filePath"],
        orderName = json["orderName"],
        qrCode = json["qrCode"],
        barCode = json["barCode"],
        process = json["process"],
        numbers = json["numbers"],
        controller = TextEditingController(text: json["numbers"]);

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["filePath"] = filePath;
    map["orderName"] = orderName;
    map["qrCode"] = qrCode;
    map["barCode"] = barCode;
    map["process"] = process;
    map["numbers"] = controller.text;
    return map;
  }

}
