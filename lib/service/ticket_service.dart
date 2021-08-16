import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:com.cushion.lucs/model/ticket.dart';
import 'package:com.cushion.lucs/model/order.dart';
import 'package:com.cushion.lucs/network/api_client.dart';
import 'package:com.cushion.lucs/network/message_response.dart';
import 'package:dio/dio.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';
import 'package:com.cushion.lucs/extentions.dart';

import 'order_service.dart';

class TicketService extends GetxController {
  DirectoryWatcher? watcher;

  // ignore: close_sinks
  final asyncMessages = BehaviorSubject<String?>();

  // ignore: close_sinks
  final tickets = BehaviorSubject<List<Ticket>>.seeded([]);
  final pref = Get.find<SharedPreferences>();

  // ignore: close_sinks
  final orderName = BehaviorSubject.seeded(OrderNameMega);

  // ignore: close_sinks
  final orderType = BehaviorSubject.seeded(OrderTypeAuto);

  // ignore: close_sinks
  final scanFolder = BehaviorSubject<String>.seeded("");
  final driveFolder = BehaviorSubject<String>.seeded("");

  final extraOrderUserIdController = TextEditingController();

  @override
  void onInit() {
    scanFolder.value = pref.getString("incomingFolder") ?? "";
    driveFolder.value = pref.getString("driveFolder") ?? "";

    if (scanFolder.value != "") {
      startWatcher();
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
      scanFolder.value = path;
      pref.setString("incomingFolder", path);
      startWatcher();
    }
  }

  selectDriveDir(BuildContext context) async {
    var rootPath = "/";
    if (Platform.isWindows) {
      rootPath = "file:///C:";
    }

    final path = await FilesystemPicker.open(
      rootName: "내 컴퓨터",
      title: '구글 드라이브 폴더 선택',
      context: context,
      rootDirectory: Directory.fromUri(Uri.parse(rootPath)),
      fsType: FilesystemType.folder,
      pickText: '처리된 이미지들을 이 폴더로 옮깁니다.',
      folderIconColor: context.theme.primaryColor,
    );

    if (path != null) {
      driveFolder.value = path;
      pref.setString("driveFolder", path);
    }
  }

  List<FileSystemEntity> filesInScanFolder() {
    return scanDirectory
            ?.listSync()
            .where((element) =>
                element.path.toLowerCase().endsWith("jpg") ||
                element.path.toLowerCase().endsWith("jpeg") ||
                element.path.toLowerCase().endsWith("png"))
            .toList() ??
        [];
  }

  uploadFilesInScanFolder() {
    filesInScanFolder().forEach((element) {
      onFileAdded(element.path);
    });
  }

  clearScanFolder() {
    filesInScanFolder().forEach((element) {
      element.delete();
    });
  }

  Directory? get scanDirectory => scanFolder.value == ""
      ? null
      : Directory.fromRawPath(Uint8List.fromList(scanFolder.value.codeUnits));

  startWatcher() {
    final path = scanFolder.value;

    if (path == "") {
      return;
    }

    watcher = DirectoryWatcher(path);
    watcher?.events.listen((event) {
      if (event.type == ChangeType.ADD) {
        onFileAdded(event.path);
      } else if (event.type == ChangeType.REMOVE) {
        onFileRemoved(event.path);
      }
    });
  }

  onFileRemoved(String filePath) async {
    tickets.value = tickets.value
      ..removeWhere((element) => element.filePath == filePath);
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

  post(Ticket t, {String? extraOrderUserId}) async {
    t.process = TicketProcessProcessing;
    t.orderName = orderName.value;
    modify(t);

    var json = t.toJson();
    print(json);
    json["file"] = await MultipartFile.fromFile(t.filePath,
        filename: t.filePath.split(pathDelim).last);
    json["orderType"] = orderType.value;
    json["extraOrderUserId"] = extraOrderUserId;

    var formData = FormData.fromMap(json);

    try {
      final res = await apicli.post<dynamic>('/tickets', data: formData);
      debugPrint(jsonEncode(res.data));
      final posted = Ticket.fromJson(res.data);

      if (posted.process == TicketProcessMatched) {
        tickets.value = tickets.value
          ..removeWhere((element) => element.filePath == t.filePath);

        posted.filePath = t.filePath;
        backupMatchedTicket(posted);
      } else {
        modify(posted);

        if (posted.process == TicketProcessReadError) {
          copyReadFailedTicket(posted);
        }
      }
    } catch (e) {
      printError(info: e.toString());
      t.process = TicketProcessSystemError;
      modify(t);
    }
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }

  Future<File> copyFileToDir(File sourceFile, String newPath) async {
    return sourceFile.copy(newPath);
  }

  modify(Ticket t) {
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

    File.fromRawPath(Uint8List.fromList(t.filePath.codeUnits)).deleteSync();
  }

  sendUploadNoti() async {
    try {
      final res =
          await apicli.get<dynamic>('/orders/status/ticket-upload-noti');
      final messageResponse = MessageResponse.fromMap(res.data);
      asyncMessages.value = messageResponse.message;
    } on DioError catch (e) {
      asyncMessages.value = e.responseMessage;
    }
  }

  bool registerExtraOrder(Ticket t) {
    if (extraOrderUserIdController.text.trim().length < 10) {
      asyncMessages.add("고객 아이디를 입력하세요");
      return false;
    }

    post(t, extraOrderUserId: extraOrderUserIdController.text);
    return true;
  }

/*
  moveTicketTo(Ticket t, List<String> driveRelativePath){
    final dirString = driveFolder.value + pathDelim + driveRelativePath.join(pathDelim);
    final dir = File.fromRawPath(Uint8List.fromList(dirString.codeUnits));

    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }
*/

  void backupRemainTickets() {
    final dirString = driveFolder.value +
        pathDelim +
        DateTime.now().format("yyyy-MM-dd") +
        pathDelim +
        "remains";
    final dir = Directory.fromRawPath(Uint8List.fromList(dirString.codeUnits));

    dir.createSync(recursive: true);

    tickets.value
        .map((e) => File.fromRawPath(Uint8List.fromList(e.filePath.codeUnits)))
        .forEach((file) {
      moveFile(file, dir.path + pathDelim + file.path.lastPathComponent);
    });
  }

  void copyReadFailedTicket(Ticket t) {
    if (driveFolder.value == "") {
      return;
    }

    final file = File.fromRawPath(Uint8List.fromList(t.filePath.codeUnits));
    final dirString = driveFolder.value +
        pathDelim +
        DateTime.now().format("yyyy-MM-dd") +
        pathDelim +
        "read_failed";
    final dir = Directory.fromRawPath(Uint8List.fromList(dirString.codeUnits));

    dir.createSync(recursive: true);

    copyFileToDir(file, dirString + pathDelim + file.path.lastPathComponent);
  }

  void backupMatchedTicket(Ticket t) {
    final file = File.fromRawPath(Uint8List.fromList(t.filePath.codeUnits));
    final dirString = driveFolder.value +
        pathDelim +
        DateTime.now().format("yyyy-MM-dd") +
        pathDelim +
        t.orderName! +
        "_" +
        orderType.value.engText;
    final dir = Directory.fromRawPath(Uint8List.fromList(dirString.codeUnits));

    dir.createSync(recursive: true);

    if (driveFolder.value != "") {
      moveFile(
          file,
          dirString +
              pathDelim +
              "${t.userName ?? ""}_${t.time ?? DateTime.now().millisecondsSinceEpoch}.jpg");
    } else {
      file.deleteSync();
    }
  }
}
