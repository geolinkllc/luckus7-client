import 'package:com.cushion.lucs/model/order.dart';
import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:com.cushion.lucs/service/print_mega.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'order_service.dart';
import 'print_power.dart';

class TicketPrintService extends GetxController {
  final orderService = Get.find<OrderService>();

  printTickets() async {
    final status = orderService.status.value;

    if (status == null) {
      return;
    }

    final doc = pw.Document();

    renderGamePages(status.mega, OrderNameMega).forEach((element) {
      doc.addPage(element);
    });
    renderGamePages(status.power, OrderNamePower).forEach((element) {
      doc.addPage(element);
    });

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  List<pw.Page> renderGamePages(GameOrderStatus status, OrderName orderName) {
    final orders = <Order>[];
    orders.addAll(status.manualOrders);
    // orders.addAll(status.autoOrders);
    final pageOrders = <Order>[];
    final pages = <pw.Page>[];

    while (orders.isNotEmpty) {
      pageOrders.add(orders.removeAt(0));
      if (pageOrders.length % 3 == 0 || orders.isEmpty) {
        final page = orderName == OrderNameMega ? renderMegaPage(pageOrders) : renderPowerPage(pageOrders);
        pages.add(page);
        pageOrders.clear();
      }
    }
    return pages;
  }
}
