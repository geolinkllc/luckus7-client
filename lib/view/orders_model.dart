import 'package:get/get.dart';
import 'package:luckus7/model/order.dart';

class OrdersModel extends GetxController{
  late Stream<Iterable<Order>> orders;

  @override
  void onInit() {
    // orders = Stream.fromIterable([Order(OrderState.ordered, 2, [], [], DateTime.now())]);
    orders = Stream.value([Order(OrderStateOrdered, 2, [["1","2","3"]], [], DateTime.now())]);

    // orders = FirebaseFirestore.instance
    //     .collection("orders")
    //     .where("orderState", isEqualTo: OrderStateOrdered)
    //     .orderBy("orderedAt", descending: false)
    //     .snapshots()
    //     .map((event) => event.docs.map((e) => Order.fromMap(e.data())));

    super.onInit();
  }
}