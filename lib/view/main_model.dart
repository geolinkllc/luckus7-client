import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'orders_page.dart';
import 'tickets_page.dart';

class MainModel extends GetxController{
  final pages = [OrdersPage(), TicketsPage()];
  final pageIndex = 0.obs;

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

    if( Platform.isWindows )
      rootPath = "file:///C:";

    Directory? dir = await getDownloadsDirectory();
    if( dir == null )
      dir = await getApplicationDocumentsDirectory();

      FilesystemPicker.open(
        title: 'Save to folder',
        context: context,
        rootDirectory: Directory.fromUri(Uri.parse(rootPath)),
        fsType: FilesystemType.folder,
        pickText: 'Save file to this folder',
        folderIconColor: context.theme.primaryColor,
      );
  }
}