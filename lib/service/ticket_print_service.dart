import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/model/order_status.dart';
import 'package:luckus7/service/order_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TicketPrintService extends GetxController {
  final orderService = Get.find<OrderService>();

  printTickets() async {
    final status = orderService.status.value;

    if (status == null) {
      return;
    }

    final doc = pw.Document();

    renderGamePages(status.mega).forEach((element) {
      doc.addPage(element);
    });
    renderGamePages(status.power).forEach((element) {
      doc.addPage(element);
    });

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  List<pw.Page> renderGamePages(GameOrderStatus status) {
    final orders = status.manualOrders;
    final pageOrders = <Order>[];
    final pages = <pw.Page>[];

    while (orders.isNotEmpty) {
      pageOrders.add(orders.removeAt(0));
      if (pageOrders.length % 4 == 0 || orders.isEmpty) {
        final page = renderPage(pageOrders);
        pages.add(page);
        pageOrders.clear();
      }
    }
    return pages;
  }

  pw.Page renderPage(List<Order> orders) {
    final orderWidgets = orders.map((e) => renderOrder(e)).toList();

    return pw.Page(
        margin: pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4,
        // orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          // return pw.Column(children: orders.map((e) => renderOrder(e)).toList());
          return pw.Column(children: orderWidgets);
          // return pw.Column(children: [pw.Text("page"),pw.Text("page"),pw.Text("page"),pw.Text("page")]);
          // return pw.Text("page");
        });
  }

  pw.Widget renderOrder(Order order) {
    final border = const pw.BorderSide(width: 1, color: PdfColor(0, 0, 0));
    return pw.Container(
        height: 180,
        margin: pw.EdgeInsets.only(bottom: 16),
        decoration: pw.BoxDecoration(
            border: pw.Border(
                left: border, bottom: border, right: border, top: border)),
        child: pw.Row(
            children: order.orderNumbers
                .map((e) => renderPlay(e))
                .expand((element) =>
                    [pw.Padding(child:element, padding: pw.EdgeInsets.all(4)), pw.Container(width: 8, color: PdfColor(1, 0, 0))])
                .toList()));
  }

  pw.Widget renderPlay(Play play) {
    final white = renderWhite(play);
    final special = renderSpecial(play);

    return pw.Column(children: [white, pw.SizedBox(height: 16), special]);
  }

  pw.Table renderWhite(Play number) {
    final rows = <pw.TableRow>[];

    for (int i = 0; i < 11; i++) {
      rows.add(renderRow(1 + i * 7, number.whiteBalls));
    }

    return pw.Table(children: rows);
  }

  pw.Table renderSpecial(Play number) {
    final rows = <pw.TableRow>[];

    for (int i = 0; i < 4; i++) {
      rows.add(renderRow(1 + i * 7, [number.specialBall]));
    }

    return pw.Table(children: rows);
  }

  pw.TableRow renderRow(int from, List<int> marked) {
    final cells = <pw.Widget>[];

    for (int i = from; i < from + 7; i++) {
      cells.add(renderCell(i, marked.contains(i)));
    }

    return pw.TableRow(children: cells);
  }

  pw.Widget renderCell(int number, bool marked) {
    debugPrint(number.toString());
    final color = marked ? 0.0 : 1.0;
    return pw.Row(children: [
      pw.Container(
        alignment: pw.Alignment.center,
        margin: pw.EdgeInsets.only(right: 3, bottom: 3),
        color: PdfColor(color, color, color),
        width: 7,
        height: 7,
        child: pw.Text(number.toString(),
            style: pw.TextStyle(fontSize: 5, color: PdfColor(1, 0, 0))),
      )
    ]);
  }
}
