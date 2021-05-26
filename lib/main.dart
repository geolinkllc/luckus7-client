import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luckus7/view/main_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';

import 'service/order_service.dart';
import 'view/main_page.dart';

Future<void> main() async {
  var watcher = DirectoryWatcher("/Users/imac/Downloads");
  watcher.events.listen((event) {
    print(event);
  });

  WidgetsFlutterBinding.ensureInitialized();
  Get.put(await SharedPreferences.getInstance(), permanent: true);
  Get.put(OrderService(), permanent: true);
  Get.put(MainModel(), permanent: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Luckus7',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          // brightness: Brightness.dark,
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(left: 12, right: 8),
            border: OutlineInputBorder(),
            // enabledBorder: OutlineInputBorder(
            //     borderSide: BorderSide(color:Theme.of(context).dividerColor)),
          )),
      home: MainPage(),
    );
  }
}
