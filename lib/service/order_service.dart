import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:luckus7/model/order_status.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrderService extends GetxController {
  // ignore: close_sinks
  final status = BehaviorSubject<OrderStatus?>();

  @override
  void onInit() {
    super.onInit();
    loadOrderStatus();
  }

  loadOrderStatus({forceRefresh = false}) async {
    if (forceRefresh) status.value = null;

    final res =
        await Dio().get<dynamic>('http://52.79.208.66:8080/orders/status');
    status.value = OrderStatus.fromJson(res.data);
  }

  printManualOMR() async {
    final doc = pw.Document();

    doc.addPage(pw.Page(
        margin: pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4,
        // orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Row(children: [
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Table(
                    defaultColumnWidth: pw.FixedColumnWidth(20),
                    children: [
                  pw.TableRow(children: [
                    pw.Container(
                        color: PdfColor(0, 0, 0),
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.symmetric(horizontal: 5)),
                    pw.Container(
                        color: PdfColor(0, 0, 0),
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.symmetric(horizontal: 5)),
                    pw.Container(
                        color: PdfColor(0, 0, 0),
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.symmetric(horizontal: 5)),
                    pw.Container(
                        color: PdfColor(0, 0, 0),
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.symmetric(horizontal: 5)),
                    pw.Container(
                        color: PdfColor(0, 0, 0),
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.symmetric(horizontal: 5)),
                    pw.Container(
                        color: PdfColor(0, 0, 0),
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.symmetric(horizontal: 5)),
                    pw.Container(
                        color: PdfColor(0, 0, 0),
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.symmetric(horizontal: 5)),
                  ])
                ]))
          ]);
        }));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}
