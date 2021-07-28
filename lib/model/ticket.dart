import 'package:flutter/cupertino.dart';

import 'order.dart';

typedef TicketProcess = String;

const TicketProcessProcessing = "processing";
const TicketProcessMatched = "matched";
const TicketProcessReadFailed = "readFailed";
const TicketProcessReadError = "readError";
const TicketProcessMatchFailed = "matchFailed";
const TicketProcessAssignError = "assignError";
const TicketProcessSystemError = "systemError";
const TicketProcessNetworkError = "networkError";
const TicketProcessClosed = "closed";
const TicketProcessInvalidDrawNumber = "invalidDrawNumber";
const TicketProcessAlreadyAssigned = "alreadyAssigned";
const TicketProcessInvalidNumber = "invalidNumber";
const TicketProcessCompanyOrderError = "companyOrderError";

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
      case TicketProcessSystemError:
        return "시스템오류";
      case TicketProcessClosed:
        return "마감된회차";
      case TicketProcessInvalidDrawNumber:
        return "유효하지않은회차";
      case TicketProcessAlreadyAssigned:
        return "발급완료된복권";
      case TicketProcessInvalidNumber:
        return "유효하지않은번호";
      case TicketProcessNetworkError:
        return "네트워크오류";
      case TicketProcessCompanyOrderError:
        return "회사주문생성오류";
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
  int? drawNumber;
  String? userName;
  int? time;
  TextEditingController drawNumberController;
  TextEditingController numbersController;

  Ticket(this.filePath,
      {this.orderName,
      this.qrCode,
      this.barCode,
      this.numbers,
      this.drawNumber,
      this.userName,
      this.time,
      this.process = TicketProcessProcessing})
      : drawNumberController =
            TextEditingController(text: drawNumber?.toString() ?? ""),
        numbersController = TextEditingController(text: numbers);

  Ticket.fromJson(dynamic json)
      : filePath = json["filePath"],
        orderName = json["orderName"],
        qrCode = json["qrCode"],
        barCode = json["barCode"],
        process = json["process"],
        numbers = json["numbers"],
        drawNumber = json["drawNumber"],
        userName = json["userName"],
        time = json["time"],
        drawNumberController =
            TextEditingController(text: "${json["drawNumber"] ?? ''}"),
        numbersController = TextEditingController(text: json["numbers"]);

  Map<String, dynamic> toJson() {
    final drawNumberText = drawNumberController.text;
    final drawNumber = drawNumberText != "" ? int.parse(drawNumberText) : 0;
    var map = <String, dynamic>{};
    map["filePath"] = filePath;
    map["orderName"] = orderName;
    map["qrCode"] = qrCode;
    map["barCode"] = barCode;
    map["process"] = process;
    map["drawNumber"] = drawNumber;
    map["userName"] = userName;
    map["time"] = time;
    map["numbers"] = numbersController.text;
    return map;
  }
}
