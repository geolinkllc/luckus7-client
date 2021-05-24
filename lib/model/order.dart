
typedef OrderNumber = List<String>;

extension OrderNumberExt on OrderNumber{
  String get str => this.join("  ");
}

typedef OrderState = String;
const OrderStateOrdered = "ordered";
const OrderStatePurchased = "purchased";

typedef OrderSelectionType = String;
const OrderSelectionTypeAuto = "auto";
const OrderSelectionTypeManual = "manual";

class Order {
  OrderState orderState = OrderStateOrdered;
  DateTime orderedAt = DateTime.now();
  DateTime? issuedAt;
  int autoCnt;
  int totalCnt;
  List<OrderNumber> manualNumbers = [];
  List<OrderNumber> issuedNumbers = [];

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  Order(this.orderState, this.autoCnt, this.manualNumbers, this.issuedNumbers,
      this.orderedAt,
      {this.issuedAt})
      : totalCnt = autoCnt + manualNumbers.length;

  factory Order.fromMap(Map<String, dynamic> map) {
    return new Order(
      map['orderState'] as OrderState,
      map['autoCnt'] as int,
      map['manualNumbers'] as List<OrderNumber>,
      map['issuedNumbers'] as List<OrderNumber>,
      map['orderedAt'] as DateTime,
      issuedAt: map['issuedAt'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'orderState': this.orderState,
      'autoCnt': this.autoCnt,
      'totalCnt': this.totalCnt,
      'manualNumbers': this.manualNumbers,
      'issuedNumbers': this.issuedNumbers,
      'orderedAt': this.orderedAt,
      'issuedAt': this.issuedAt,
    } as Map<String, dynamic>;
  }

//</editor-fold>

}
