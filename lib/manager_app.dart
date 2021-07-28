import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network/api_client.dart';
import 'service/order_service.dart';
import 'manager_view/manager_main_page.dart';
import 'service/ticket_print_service.dart';
import 'service/ticket_service.dart';

const flavor = String.fromEnvironment('flavor', defaultValue: 'prod');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ApiClient.create(), permanent: true);
  Get.put(await SharedPreferences.getInstance(), permanent: true);
  Get.put(OrderService(), permanent: true);
  Get.put(TicketPrintService(), permanent: true);
  Get.put(TicketService(), permanent: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Luckus7',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                primary: Colors.blue, backgroundColor: Colors.white),
          ),
          primarySwatch: Colors.blue,
          // brightness: Brightness.dark,
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(left: 12, right: 8),
            border: OutlineInputBorder(),
            // enabledBorder: OutlineInputBorder(
            //     borderSide: BorderSide(color:Theme.of(context).dividerColor)),
          )),
      home: ManagerMainPage(),
    );
  }
}
