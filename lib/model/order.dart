// typedef GameType = String;
// const GameTypeMega = "mega";
// const GameTypePower = "power";
//
// typedef OrderSelectionType = String;
// const OrderSelectionTypeAuto = "auto";
// const OrderSelectionTypeManual = "manual";

typedef OrderState = String;
const OrderStateOrdered = "ordered";
const OrderStatePurchased = "purchased";

typedef OrderName = String;
const OrderNameMega = "mega";
const OrderNamePower = "power";

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
