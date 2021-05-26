import 'dart:io';

import 'package:dio/dio.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:luckus7/model/order_status.dart';
import 'package:luckus7/model/ticket.dart';
import 'package:luckus7/service/order_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';

class ScanService extends GetxController {
  DirectoryWatcher? watcher;
  // ignore: close_sinks
  final tickets = BehaviorSubject<List<Ticket>>.seeded([]);
  final pref = Get.find<SharedPreferences>();
  // ignore: close_sinks
  final incomingFolder = BehaviorSubject<String>.seeded("");

  @override
  void onInit() {
    incomingFolder.value = pref.getString("incomingFolder") ?? "";

    if( incomingFolder.value != "") {
      startWatcher(incomingFolder.value);
    }

    super.onInit();
  }

  selectIncomingDir(BuildContext context) async {
    // final file = OpenFilePicker()
    //   ..filterSpecification = {
    //     'Word Document (*.doc)': '*.doc',
    //     'Web Page (*.htm; *.html)': '*.htm;*.html',
    //     'Text Document (*.txt)': '*.txt',
    //     'All Files': '*.*'
    //   }
    //   ..defaultFilterIndex = 0
    //   ..defaultExtension = 'doc'
    //   ..title = 'Select a document';
    //
    // final result = file.getFile();
    // if (result != null) {
    //   print(result.path);
    // }

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

  startWatcher(String path){
    watcher = DirectoryWatcher(path);
    watcher?.events.listen((event) {
      if( event.type == ChangeType.ADD) {
        onFileAdded(event.path);
      }
    });
  }

  onFileAdded(String filePath) {
    printInfo(info: "onFileAdded:" + filePath);
    final ticket = Ticket(filePath);
    tickets.value = tickets.value..insert(0, ticket);
    upload(filePath);
  }

  upload(String path) async {
    final pathDelim = Platform.isWindows ? "\\" : "/";

    var formData = FormData.fromMap({
      'filePath': path,
      'file': await MultipartFile.fromFile(path, filename: path.split(pathDelim).last),
    });

    final res = await Dio().post<dynamic>('http://34.134.22.192:8080/upload', data: formData);
    final ticket = Ticket.fromJson(res.data);
    tickets.value = tickets.value..insert(0, ticket);

    Get.find<OrderService>().loadOrderStatus(forceRefresh: false);
  }
}
