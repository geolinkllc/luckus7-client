import 'package:com.cushion.lucs/extentions.dart';
import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final ticketWidth = 18.75.cm;
final ticketHeight = 8.25.cm;
final columnCnt = 53;
final redColor = const PdfColor(1, 0.5, 0.5);

pw.Page renderPowerPage(List<Order> orders) {
  final games = <pw.Widget>[];
  games.add(pw.Container(
      width: double.infinity, height: 0.5, color: redColor));
  orders.forEach((element) {
    games.add(pw.Row(children: [
      renderPowerOrder(element),
      pw.Expanded(child: pw.Container()),
      pw.Text("P\nO\nW\nE\nR\nB\nA\nL\nL", style: pw.TextStyle(color: redColor)),
    ]));
    games.add(pw.Container(
        width: double.infinity, height: 0.5, color: redColor));
  });

  return pw.Page(
      margin: pw.EdgeInsets.all(20),
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.portrait,
      build: (pw.Context context) {
        // return pw.Column(children: orders.map((e) => renderOrder(e)).toList());
        return pw.Column(
            children: games,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start);
        // return pw.Column(children: [pw.Text("page"),pw.Text("page"),pw.Text("page"),pw.Text("page")]);
        // return pw.Text("page");
      });
}

pw.Widget renderPowerOrder(Order order) {
  final plays = order.orderNumbers;
  final rows = <pw.TableRow>[];
  rows.add(powerTopMarkers());
  rows.add(powerEmptyRow());

  for (var whiteRowIndex = 0; whiteRowIndex < 7; whiteRowIndex++) {
    final colIndexesToMark = <int>[];

    plays.forEach((play) {
      int playIndex = plays.indexOf(play);
      colIndexesToMark
          .addAll(play.whiteIndexesToMark(playIndex, whiteRowIndex));
    });

    if (whiteRowIndex == 2 || whiteRowIndex == 3) {
      colIndexesToMark.add(columnCnt - 1);
    }

    rows.add(powerRow(colIndexesToMark, whiteRowIndex));
  }
  rows.add(powerEmptyRow());

  for (var specialRowIndex = 0; specialRowIndex < 3; specialRowIndex++) {
    final colIndexesToMark = <int>[];
    plays.forEach((play) {
      int playIndex = plays.indexOf(play);
      colIndexesToMark
          .addAll(play.specialIndexesToMark(playIndex, specialRowIndex));
    });
    rows.add(powerRow(colIndexesToMark, specialRowIndex));
  }

  rows.add(powerBottomMarkers());

  return pw.Container(
      height: ticketHeight,
      width: ticketWidth,
      // margin: pw.EdgeInsets.only(bottom: 1),
      // decoration: pw.BoxDecoration(
      //     border: pw.Border(
      //         left: border, bottom: border, right: border, top: border)),
      child: pw.Table(children: rows));
}

pw.TableRow powerEmptyRow() {
  final markers = <pw.Widget>[];
  for (var i = 0; i < columnCnt; i++) {
    markers.add(powerMarker(0, false));
  }
  return pw.TableRow(children: markers);
}

pw.TableRow powerRow(List<int> indexesToMark, int rowIndex) {
  final markers = <pw.Widget>[];
  for (var i = 0; i < columnCnt; i++) {
    int num = i;
    if (num < 2 || i == columnCnt - 1) {
      num = 0;
    } else {
      num = (i - 2) % 10 + 1 + rowIndex * 10;
    }
    markers.add(powerMarker(num, indexesToMark.contains(i)));
  }
  return pw.TableRow(children: markers);
}

pw.TableRow powerTopMarkers() {
  final markers = <pw.Widget>[];
  for (var i = 0; i < columnCnt; i++) {
    markers.add(columnPositionMarker(true));
  }
  return pw.TableRow(children: markers);
}

pw.TableRow powerBottomMarkers() {
  final markers = <pw.Widget>[];
  markers.add(columnPositionMarker(true));
  for (var i = 1; i < columnCnt - 1; i++) {
    markers.add(columnPositionMarker(false));
  }
  markers.add(columnPositionMarker(true));
  return pw.TableRow(children: markers);
}

pw.Widget columnPositionMarker(bool marked) {
  return pw.Container(
      // width: 0.356.cm,
      height: 0.275.cm,
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
        pw.Container(
            width: 0.2.cm,
            height: 0.3.cm,
            color: marked ? PdfColor(0, 0, 0) : PdfColor(1, 1, 1))
      ]));
}

pw.Widget powerMarker(int number, bool marked) {
  return pw.Container(
      alignment: pw.Alignment.center,
      height: 0.635.cm,
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
        pw.Container(
            alignment: pw.Alignment.center,
            // child: number <= 0
            //     ? null
            //     : pw.Text(number.toString(),
            //         style: pw.TextStyle(fontSize: 5, color: PdfColor(1, 1, 1))),
            width: 0.2.cm,
            height: 0.4.cm,
            color: marked ? PdfColor(0, 0, 0) : PdfColor(1, 1, 1))
      ]));
}
