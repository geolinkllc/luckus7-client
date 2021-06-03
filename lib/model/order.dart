// typedef GameType = String;
// const GameTypeMega = "mega";
// const GameTypePower = "power";
//
// typedef OrderSelectionType = String;
// const OrderSelectionTypeAuto = "auto";
// const OrderSelectionTypeManual = "manual";

typedef OrderState = String;
const OrderState OrderStateOrdered = "ordered";
const OrderState OrderStatePurchased = "purchased";

typedef OrderName = String;
const OrderName OrderNameMega = "mega";
const OrderName OrderNamePower = "power";

typedef OrderType = int;
const OrderType OrderTypeManual = 1;
const OrderType OrderTypeAuto = 2;

extension OrderNameExtention on OrderName {
  String get name {
    switch (this) {
      case OrderNameMega:
        return "메가";
      default:
        return "파워";
    }
  }
}
