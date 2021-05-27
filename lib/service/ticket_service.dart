import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:luckus7/model/order_status.dart';
import 'package:luckus7/model/ticket.dart';
import 'package:luckus7/model/order.dart';
import 'package:luckus7/service/order_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';

class TicketService extends GetxController {
  DirectoryWatcher? watcher;

  // ignore: close_sinks
  final tickets = BehaviorSubject<List<Ticket>>.seeded([]);
  final pref = Get.find<SharedPreferences>();

  // ignore: close_sinks
  final incomingFolder = BehaviorSubject<String>.seeded("");

  @override
  void onInit() {
    incomingFolder.value = pref.getString("incomingFolder") ?? "";

    if (incomingFolder.value != "") {
      startWatcher(incomingFolder.value);
    }

    super.onInit();
  }

  selectIncomingDir(BuildContext context) async {
    var rootPath = "/";
    if (Platform.isWindows) {
      rootPath = "file:///C:";
    }

    final path = await FilesystemPicker.open(
      rootName: "내 컴퓨터",
      title: '스캔 이미지 폴더 선택',
      context: context,
      rootDirectory: Directory.fromUri(Uri.parse(rootPath)),
      fsType: FilesystemType.folder,
      pickText: '이 폴더의 이미지들을 자동으로 입력합니다',
      folderIconColor: context.theme.primaryColor,
    );

    if (path != null) {
      incomingFolder.value = path;
      pref.setString("incomingFolder", path);
      startWatcher(path);
    }
  }

  startWatcher(String path) {
    Directory dir;
    try{
      dir = Directory.fromUri(Uri.parse(path));
    }catch(e){
      debugPrint(path);
      pref.setString("incomingFolder", "");
      incomingFolder.value = "";
      return
    }

    dir.listSync().forEach((element) {
      onFileAdded(element.path);
    });

    watcher = DirectoryWatcher(path);
    watcher?.events.listen((event) {
      if (event.type == ChangeType.ADD) {
        onFileAdded(event.path);
      }
    });
  }

  onFileAdded(String filePath) async {
    if (!filePath.toLowerCase().endsWith("png") &&
        !filePath.toLowerCase().endsWith("jpg") &&
        !filePath.toLowerCase().endsWith("jpeg")) {
      return;
    }

    printInfo(info: "onFileAdded:" + filePath);
    final ticket = Ticket(filePath);
    tickets.value = tickets.value..insert(0, ticket);
    await post(ticket);
  }

  post(Ticket t) async {
    t.process = TicketProcessProcessing;
    modify(t);

    final pathDelim = Platform.isWindows ? "\\" : "/";

    var json = t.toJson();
    json["file"] = await MultipartFile.fromFile(t.filePath,
        filename: t.filePath.split(pathDelim).last);

    var formData = FormData.fromMap(json);

    try {
      final res = await Dio()
          .post<dynamic>('http://34.134.22.192:8080/tickets', data: formData);
      debugPrint(jsonEncode(res.data));
      final posted = Ticket.fromJson(res.data);

      if (posted.process == TicketProcessMatched) {
        tickets.value = tickets.value
          ..removeWhere((element) => element.filePath == t.filePath);

        File.fromUri(Uri.parse(t.filePath)).deleteSync();
        Get.find<OrderService>().loadOrderStatus(forceRefresh: false);
      } else {
        modify(posted);
      }
    } on Exception catch (e) {
      e.printError();

    }
  }

  modify( Ticket t ){
    final index =
    tickets.value.indexWhere((element) => element.filePath == t.filePath);
    final ticketValues = tickets.value;
    ticketValues[index] = t;
    tickets.value = ticketValues;
  }

  selectTicketOrderName(Ticket t, OrderName name) {
    t.orderName = name;
    modify(t);
  }

  void delete(Ticket t) {
    tickets.value = tickets.value
      ..removeWhere((element) => element.filePath == t.filePath);

    File.fromUri(Uri.parse(t.filePath)).deleteSync();
  }
}
