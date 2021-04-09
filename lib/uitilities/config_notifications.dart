import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ConfigNotifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    "0",
    "Workout Remainder",
    "Remainder about your daily workouts",
    icon: "notification_logo",
    playSound: true,
    importance: Importance.high,
    enableLights: true,
    visibility: NotificationVisibility.public,
  );

  static const IOSNotificationDetails iosNotificationDetails =
      IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: iosNotificationDetails,
  );

  static final ConfigNotifications _singelton = ConfigNotifications._();
  static ConfigNotifications get instance => _singelton;

  ConfigNotifications._() {
    initalize();
  }

  initalize() async {
    tz.initializeTimeZones();

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_logo');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        // print(payload);
      },
    );
  }

  Future<DateTime> updateNotificationSchedules(
    DateTime notificationsScheduledTill,
    Set<int> selectedDays,
    TimeOfDay timeOfDay,
  ) async {
    if (notificationsScheduledTill != null &&
        notificationsScheduledTill.isBefore(DateTime.now())) {
      return await scheduleRemainders(
        selectedDays,
        timeOfDay,
      );
    } else
      return null;
  }

  Future<DateTime> scheduleRemainders(
    Set<int> selectedDays,
    TimeOfDay timeOfDay,
  ) async {
    await cancelAll();
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    DateTime monthEnd = DateTime(
      now.year,
      now.month + 1,
      0,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    // Add one day if the time is ellapsed
    if (dateTime.isBefore(now)) {
      dateTime = dateTime.add(const Duration(days: 1));
    }
    int differnce = monthEnd.difference(dateTime).inDays;

    String notificatioTitleData =
        await rootBundle.loadString("assets/data/notifications.json");
    List notificationTitleList = jsonDecode(notificatioTitleData);

    for (var i = 0; i <= differnce; i++) {
      if (selectedDays.contains(dateTime.weekday)) {
        String title = notificationTitleList[
            Random().nextInt(notificationTitleList.length)];
        print(tz.TZDateTime.from(dateTime, tz.local));
        // schedule a notification for selected days till this month
        await flutterLocalNotificationsPlugin.zonedSchedule(
          i,
          title,
          null,
          tz.TZDateTime.from(dateTime, tz.local),
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );
      }
      dateTime = dateTime.add(const Duration(days: 1));
    }
    return monthEnd;
  }

  cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
