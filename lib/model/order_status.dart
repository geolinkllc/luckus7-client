import 'package:com.cushion.lucs/network/api_client.dart';
import 'package:flutter/material.dart';

import 'order.dart';

class OrderStatus {
  String date;
  GameOrderStatus mega;
  GameOrderStatus power;
  bool isComplete;

  OrderStatus(this.date, this.mega, this.power, this.isComplete);

  OrderStatus.fromJson(dynamic json)
      : date = json["date"],
        mega = GameOrderStatus.fromJson(json["mega"]),
        power = GameOrderStatus.fromJson(json["power"]),
        isComplete = json["isComplete"];

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["date"] = date;
    map["mega"] = mega.toJson();
    map["power"] = power.toJson();
    map["isComplete"] = isComplete;
    return map;
  }

  updateOrder(Order order) {
    mega.updateOrder(order);
    power.updateOrder(order);
  }

  List<Order> getIssuedOrders(
      OrderName orderName, OrderType orderType, int gamesCnt) {
    final gameStatus = getGameStatus(orderName);

    if (orderType == OrderTypeManual) {
      return gameStatus.manualOrders
          .where((element) =>
              element.isIssued &&
              (gamesCnt == 0 || element.orderNumbers.length == gamesCnt))
          .toList();
    } else {
      return gameStatus.autoOrders
          .where((element) =>
              element.isIssued &&
              (gamesCnt == 0 || element.orderNumbers.length == gamesCnt))
          .toList();
    }
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
  List<Order> autoOrders = [];

  GameOrderStatus(this.autoOrderCounts, this.manualOrders);

  GameOrderStatus.fromJson(dynamic json) {
    autoOrderCounts.addAll((json["autoOrderCounts"] as List<dynamic>)
        .map((e) => AutoOrderCount.fromJson(e)));
    manualOrders.addAll(
        (json["manualOrders"] as List<dynamic>).map((e) => Order.fromJson(e)));
    autoOrders.addAll(
        (json["autoOrders"] as List<dynamic>).map((e) => Order.fromJson(e)));
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["autoOrderCounts"] = autoOrderCounts.map((v) => v.toJson()).toList();
    map["manualOrders"] = manualOrders.map((v) => v.toJson()).toList();
    map["autoOrders"] = autoOrders.map((v) => v.toJson()).toList();
    return map;
  }

  List<Order> getIssuedAutoOrdersByPlayCnt(int playCnt) {
    return autoOrders
        .where((element) =>
            element.isIssued && element.orderNumbers.length == playCnt)
        .toList();
  }

  int get manualOrdersIssuedCnt =>
      manualOrders.where((element) => element.isIssued).length;

  int get manualOrderCnt => manualOrders.length;

  void updateOrder(Order order) {
    var index = manualOrders.indexWhere((element) =>
        element.userName == order.userName && element.time == order.time);
    if (index > -1) {
      manualOrders[index] = order;
      return;
    }

    index = autoOrders.indexWhere((element) =>
        element.userName == order.userName && element.time == order.time);
    if (index > -1) {
      autoOrders[index] = order;
    }
  }
}

class Order {
  int time;
  String orderName;
  int orderType;
  String userName;
  List<OrderNumber> orderNumbers = [];

  Order(this.time, this.orderName, this.orderType, this.userName,
      this.orderNumbers);

  Order.fromJson(dynamic json)
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

  int get issuedCnt =>
      orderNumbers.where((element) => element.flag == 1).length;

  int get totalCnt => orderNumbers.length;

  String get ticketImageUrl =>
      webHost + "/img/lottery/img_${orderNumbers[0].orderId}.jpg";
}

class OrderNumber {
  String orderId;
  OrderName orderName;
  OrderType orderType;
  int flag;
  String buyType;
  int time;
  TextEditingController numbersController;

  OrderNumber(this.orderId, this.orderName, this.orderType, String numbers,
      this.flag, this.buyType, this.time)
      : numbersController = TextEditingController(text: numbers);

  OrderNumber.fromJson(dynamic json)
      : orderId = json["orderId"],
        orderName = json["orderName"],
        orderType = json["orderType"],
        flag = json["flag"],
        buyType = json["buyType"],
        time = json["time"],
        numbersController = TextEditingController(text: json["numbers"]);

  String get numbers => numbersController.text;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["orderId"] = orderId;
    map["orderName"] = orderName;
    map["orderType"] = orderType;
    map["numbers"] = numbers;
    map["flag"] = flag;
    map["buyType"] = buyType;
    map["time"] = time;
    return map;
  }

  List<int> whiteIndexesToMark(int playIndex, rowIndex) {
    if (orderName == OrderNamePower) {
      int offset = 1 + playIndex * 10;
      int from = rowIndex * 10 + 1;
      int to = from + 10;
      return whiteBalls
          .where((n) => n >= from && n < to)
          .map((e) => offset + e % 10)
          .toList();
    } else {
      return [];
    }
  }

  List<int> specialIndexesToMark(int playIndex, rowIndex) {
    if (orderName == OrderNamePower) {
      int offset = 1 + playIndex * 10;
      int from = rowIndex * 10 + 1;
      int to = from + 10;
      return [specialBall]
          .where((n) => n >= from && n < to)
          .map((e) => offset + e % 10)
          .toList();
    } else {
      return [];
    }
  }

  List<int> get balls {
    return numbers
        .split(" ")
        .where((element) => element != "")
        .map((e) => int.parse(e))
        .toList();
  }

  List<int> get megaMixedLineBalls {
    return <int>[]
      ..addAll(whiteBalls.where((element) => element > 2))
      ..add(specialBall);
  }

  List<int> get whiteBalls {
    if (balls.length == 6) {
      return balls.sublist(0, 5);
    } else {
      return [];
    }
  }

  int get specialBall {
    if (balls.length == 6) {
      return balls.last;
    } else {
      return -1;
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
