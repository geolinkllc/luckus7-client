import 'order.dart';

class Ticket {
  String imagePath;
  OrderName orderName;
  String? qrCode;
  String? barCode;
  List<String> numbers = [];

  Ticket(this.imagePath, this.orderName,
      {this.qrCode, this.barCode, List<String> nums = const []}) {
    numbers.addAll(nums);
  }

  Ticket.fromJson(dynamic json)
      : imagePath = json["imagePath"],
        orderName = json["orderName"],
        qrCode = json["qrCode"],
        barCode = json["barCode"] {
    var nums = json["barCode"];
    if (nums == null) {
      return;
    }

    this
        .numbers
        .addAll((nums as List<dynamic>).map((e) => e as String).toList());
  }
}
