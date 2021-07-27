import 'package:com.cushion.lucs/model/order.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:com.cushion.lucs/model/order_status.dart';
import 'package:com.cushion.lucs/extentions.dart';

final ticketHeight = 18.75.cm;
final ticketWidth = 8.2.cm;
const rowCnt = 48;
const colCnt = 48;
final redColor = const PdfColor(1, 0.5, 0.5);

pw.Page renderMegaPage(List<Order> orders) {
  final games = <pw.Widget>[];
  games.add(pw.Container(
      width: 0.5, height: double.infinity, color: redColor));

  orders.forEach((element) {
    games.add(pw.Column(children: [
      pw.Text("MEGA MILLIONS", style: pw.TextStyle(color: redColor)),
      pw.Expanded(child: pw.Container()),
      renderMegaOrder(element)
    ], mainAxisAlignment: pw.MainAxisAlignment.start));
    games.add(pw.Container(
        width: 0.5, height: double.infinity, color: redColor));
  });
  // final orderWidgets = orders.map((e) => renderMegaOrder(e)).toList();

  return pw.Page(
      margin: pw.EdgeInsets.all(20),
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.landscape,
      build: (pw.Context context) {
        return pw.Row(
            children: games,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.start);
      });
}

pw.Widget renderMegaOrder(Order order) {
  final plays = order.orderNumbers;
  final rows = <pw.TableRow>[];

  rows.add(renderRow([0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0], [1], true, true));
  rows.add(renderRow([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1], true, false));
  rows.add(renderRow([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1], true, false));

  plays.forEach((element) {
    rows.addAll(renderPlay(element));
  });

  for (int i = plays.length; i < 5; i++) {
    rows.addAll(
        renderPlay(OrderNumber("", OrderNameMega, OrderTypeManual, "", 1, "0", 0)));
  }

  rows.add(pw.TableRow(children: [pw.Container(height: 0.85.cm)]));
  rows.add(renderRow([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1], true, true));

  return pw.Container(
      // height: ticketHeight,
      width: ticketWidth,
      // margin: pw.EdgeInsets.only(right: 1),
      // decoration: pw.BoxDecoration(
      //     border: pw.Border(
      //         left: border, bottom: border, right: border, top: border)),
      child: pw.Table(children: rows));
}

List<pw.TableRow> renderPlay(OrderNumber play) {
  final rows = <pw.TableRow>[];

  rows.add(renderRow(
      [0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8], play.whiteBalls, true, false));
  rows.add(renderRow([9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
      play.whiteBalls, true, false));
  rows.add(renderRow([21, 22, 23, 24, 25, 26, 27, 28, 28, 30, 31, 32],
      play.whiteBalls, true, false));
  rows.add(renderRow([33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44],
      play.whiteBalls, true, false));
  rows.add(renderRow([45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56],
      play.whiteBalls, true, false));
  rows.add(renderRow([57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68],
      play.whiteBalls, true, false));
  rows.add(renderRow([69, 70, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2],
      play.megaMixedLineBalls, true, false));
  rows.add(renderRow([3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
      [play.specialBall], true, false));
  rows.add(renderRow([15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 0],
      [play.specialBall], true, false));

  return rows;
}

pw.TableRow renderRow(List<int> numbers, List<int> numbersToMark,
    bool leftPositionMarker, bool rightPositionMarker) {
  final markers = <pw.Widget>[];

  markers.add(positionMarker(leftPositionMarker));

  numbers.forEach((element) {
    markers.add(marker(element, numbersToMark.contains(element)));
  });

  markers.add(positionMarker(rightPositionMarker));

  return pw.TableRow(children: markers);
}

pw.Widget positionMarker(bool marked) {
  return pw.Container(
      alignment: pw.Alignment.center,
      width: 0.3.cm,
      height: 0.355.cm,
      child: pw.Container(
          width: 0.3.cm,
          height: 0.2.cm,
          color: marked ? PdfColor(0, 0, 0) : PdfColor(1, 1, 1)));
}

pw.Widget marker(int number, bool marked) {
  return pw.Container(
      alignment: pw.Alignment.center,
      width: 0.65.cm,
      height: 0.355.cm,
      child: pw.Container(
          alignment: pw.Alignment.center,
          // child: number <= 0
          //     ? null
          //     : pw.Text(number.toString(),
          //         style: pw.TextStyle(fontSize: 5, color: redColor)),
          width: 0.4.cm,
          height: 0.2.cm,
          color: marked ? PdfColor(0, 0, 0) : PdfColor(1, 1, 1)));
}
