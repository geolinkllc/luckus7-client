class OrderStatus {
  GameOrderStatus mega;
  GameOrderStatus power;

  OrderStatus(this.mega, this.power);

  OrderStatus.fromJson(dynamic json)
      : mega = GameOrderStatus.fromJson(json["mega"]),
        power = GameOrderStatus.fromJson(json["power"]);

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["mega"] = mega.toJson();
    map["power"] = power.toJson();
    return map;
  }
}

class GameOrderStatus {
  List<AutoOrderCount> autoOrderCounts = [];
  List<ManualOrder> manualOrders = [];

  GameOrderStatus(this.autoOrderCounts, this.manualOrders);

  GameOrderStatus.fromJson(dynamic json) {
    autoOrderCounts.addAll((json["autoOrderCounts"] as List<dynamic>)
        .map((e) => AutoOrderCount.fromJson(e)));
    manualOrders.addAll((json["manualOrders"] as List<dynamic>)
        .map((e) => ManualOrder.fromJson(e)));
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["autoOrderCounts"] = autoOrderCounts.map((v) => v.toJson()).toList();
    map["manualOrders"] = manualOrders.map((v) => v.toJson()).toList();
    return map;
  }
}

class ManualOrder {
  int time;
  String orderName;
  int orderType;
  String userName;
  List<OrderNumber> orderNumbers = [];

  ManualOrder(this.time, this.orderName, this.orderType, this.userName,
      this.orderNumbers);

  ManualOrder.fromJson(dynamic json)
      : time = json["time"],
        orderName = json["orderName"],
        orderType = json["orderType"],
        userName = json["userName"] {
    orderNumbers.addAll((json["orderNumbers"] as List<dynamic>)
        .map((e) => OrderNumber.fromJson(e)));
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["time"] = time;
    map["orderName"] = orderName;
    map["orderType"] = orderType;
    map["userName"] = userName;
    map["orderNumbers"] = orderNumbers.map((v) => v.toJson()).toList();

    return map;
  }

  bool get isIssued =>
      orderNumbers.where((element) => element.flag == 1).length ==
      orderNumbers.length;
}

class OrderNumber {
  String orderName;
  int orderType;
  String numbers;
  int flag;
  String buyType;
  int time;

  OrderNumber(this.orderName, this.orderType, this.numbers, this.flag,
      this.buyType, this.time);

  OrderNumber.fromJson(dynamic json)
      : orderName = json["orderName"],
        orderType = json["orderType"],
        numbers = json["numbers"],
        flag = json["flag"],
        buyType = json["buyType"],
        time = json["time"];

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["orderName"] = orderName;
    map["orderType"] = orderType;
    map["numbers"] = numbers;
    map["flag"] = flag;
    map["buyType"] = buyType;
    map["time"] = time;
    return map;
  }
}

class AutoOrderCount {
  int totalCnt;
  int issuedCnt;

  AutoOrderCount(this.totalCnt, this.issuedCnt);

  AutoOrderCount.fromJson(dynamic json)
      : totalCnt = json["totalCnt"],
        issuedCnt = json["issuedCnt"];

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["totalCnt"] = totalCnt;
    map["issuedCnt"] = issuedCnt;
    return map;
  }
}
