import 'order.dart';

typedef TicketProcess = String;

const TicketProcessProcessing = "processing";
const TicketProcessMatched = "matched";
const TicketProcessReadFailed = "readFailed";
const TicketProcessMatchFailed = "matchFailed";
const TicketProcessAssignError = "assignError";

class Ticket {
  String filePath;
  OrderName? orderName;
  String? qrCode;
  String? barCode;
  TicketProcess process = TicketProcessProcessing;
  List<String> numberRows = [];

  Ticket(this.filePath,
      {this.orderName,
      this.qrCode,
      this.barCode,
      this.process = TicketProcessProcessing,
      List<String> nums = const []}) {
    numberRows.addAll(nums);
  }

  Ticket.fromJson(dynamic json)
      : filePath = json["filePath"],
        orderName = json["orderName"],
        qrCode = json["qrCode"],
        barCode = json["barCode"],
        process = json["process"]
  {
    var nums = json["barCode"];
    if (nums != null) {
      this
          .numberRows
          .addAll((nums as List<dynamic>).map((e) => e as String).toList());
    }
  }
}
