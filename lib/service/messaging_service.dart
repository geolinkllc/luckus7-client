import 'dart:io';

import 'package:com.luckus7.lucs/view/webview_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class MessagingService extends GetxController {
  // ignore: close_sinks
  final token = BehaviorSubject<String>();

  // ignore: close_sinks
  final asyncMessageStraem = BehaviorSubject<dynamic>();
  final messages = <String, RemoteMessage>{};
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'lottery', // id
    '복권 알림 서비스', // title
    '복권 발권과 당첨여부를 알려드립니다.', // description
    importance: Importance.max,
  );

  @override
  Future<void> onInit() async {
    super.onInit();

    initFirebaseMessaging();
    initLocalNotificationsPlugin();
  }

  initFirebaseMessaging() {
    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      debugPrint("onTokenRefresh:$event");
      token.add(event);
    });
  }

  initLocalNotificationsPlugin() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');

        final messageId = payload;
        onMessageSelected(messageId);
      }
    });
  }

  initToken() async {
    print("initToken");
    final currentToken = await FirebaseMessaging.instance.getToken();

    if (currentToken != null) {
      print("initToken:" + currentToken);
      token.add(currentToken);
    }
  }

  String storeMessage(RemoteMessage message) {
    final messageId =
        message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    messages[messageId] = message;
    return messageId;
  }

  onMessageSelected(String messageId) {
    final message = messages[messageId];
    if (message != null && message.data["in-link"] != null) {
      Get.find<WebViewController>().windowOpen(message.data["in-link"]!);
      // Get.snackbar("onMessageSelected", message.notification!.title! + " " + message.notification!.body!, backgroundColor: Colors.white);
      // messageStream.add(message);

    }
  }

  @override
  Future<void> onReady() async {
    super.onReady();

    if (Platform.isIOS) {
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      // Get.snackbar("onMessageOpenedApp", event.notification!.title!);
      final messageId = storeMessage(event);
      onMessageSelected(messageId);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      final messageId = storeMessage(message);

      if (message.notification != null &&
          message.notification?.android != null) {
        RemoteNotification notification = message.notification!;
        AndroidNotification android = message.notification!.android!;

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                styleInformation: BigTextStyleInformation(notification.body!, contentTitle: notification.title),
                icon: "ic_notification",

                // other properties...
              ),
            ),
            payload: messageId);
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        final messageId = storeMessage(value);

        Future.delayed(Duration(milliseconds: 1000))
            .then((value) => onMessageSelected(messageId));
      }
      return null;
    });
  }
}
