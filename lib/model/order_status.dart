import 'order.dart';

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

  GameOrderStatus getGameStatus(OrderName orderName) {
    switch (orderName) {
      case OrderNameMega:
        return mega;
      case OrderNamePower:
        return power;
      default:
        return mega;
    }
  }
}

class GameOrderStatus {
  List<AutoOrderCount> autoOrderCounts = [];
  List<Order> manualOrders = [];

  GameOrderStatus(this.autoOrderCounts, this.manualOrders);

  GameOrderStatus.fromJson(dynamic json) {
    autoOrderCounts.addAll((json["autoOrderCounts"] as List<dynamic>)
        .map((e) => AutoOrderCount.fromJson(e)));
    manualOrders.addAll((json["manualOrders"] as List<dynamic>)
        .map((e) => Order.fromJson(e)));
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["autoOrderCounts"] = autoOrderCounts.map((v) => v.toJson()).toList();
    map["manualOrders"] = manualOrders.map((v) => v.toJson()).toList();
    return map;
  }

  int get manualOrdersIssuedCnt =>
      manualOrders.where((element) => element.isIssued).length;

  int get manualOrderCnt => manualOrders.length;
}

class Order {
  int time;
  String orderName;
  int orderType;
  String userName;
  List<Play> orderNumbers = [];

  Order(this.time, this.orderName, this.orderType, this.userName,
      this.orderNumbers);

  Order.fromJson(dynamic json)
      : time = json["time"],
        orderName = json["orderName"],
        orderType = json["orderType"],
        userName = json["userName"] {
    orderNumbers.addAll(
        (json["orderNumbers"] as List<dynamic>).map((e) => Play.fromJson(e)));
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

  int get issuedCnt =>
      orderNumbers.where((element) => element.flag == 1).length;

  int get totalCnt => orderNumbers.length;
}

class Play {
  OrderName orderName;
  OrderType orderType;
  String numbers;
  int flag;
  String buyType;
  int time;

  Play(this.orderName, this.orderType, this.numbers, this.flag, this.buyType,
      this.time);

  Play.fromJson(dynamic json)
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

  List<int> get whiteBalls {
    if (orderType == OrderTypeAuto) {
      if (orderName == OrderNameMega) {
        return [77];
      } else {
        return [77];
      }
    } else {
      return numbers.split(" ").map((e) => int.parse(e)).toList().sublist(0, 5);
    }
  }

  int get specialBall {
    if (orderType == OrderTypeAuto) {
      if (orderName == OrderNameMega) {
        return 28;
      } else {
        return 28;
      }
    } else {
      return numbers.split(" ").map((e) => int.parse(e)).last;
    }
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
