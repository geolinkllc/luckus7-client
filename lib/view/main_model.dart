import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auto_orders_page.dart';
import 'tickets_page.dart';

class MainModel extends GetxController {
  final pages = [AutoOrdersPage(), TicketsPage()];
  final pageIndex = 0.obs;
  final incomingFolder = "".obs;
  final pref = Get.find<SharedPreferences>();

  MainModel() {
    incomingFolder.value = pref.getString("incomingFolder") ?? "";
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
    if (Platform.isWindows) rootPath = "file:///C:";

    final path = await FilesystemPicker.open(
      title: 'Save to folder',
      context: context,
      rootDirectory: Directory.fromUri(Uri.parse(rootPath)),
      fsType: FilesystemType.folder,
      pickText: 'Save file to this folder',
      folderIconColor: context.theme.primaryColor,
    );

    if (path != null) {
      incomingFolder.value = path;
      pref.setString("incomingFolder", incomingFolder.value);
    }
  }
}
