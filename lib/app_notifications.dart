import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:path_provider/path_provider.dart';

class AppNotifications {
  static FlutterLocalNotificationsPlugin _plugin;

  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  static void initialize(BuildContext context) {
    _plugin = FlutterLocalNotificationsPlugin();

    final androidInitSettings = AndroidInitializationSettings('memorare_icon');
    final iOSInitSettings = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(androidInitSettings, iOSInitSettings);

    _plugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload == null) {
          return;
        }

        debugPrint('notification payload: $payload');

        // return Future.value(true);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuotePage(quoteId: payload,))
        );
      }
    );
  }

  static void scheduleNotifications() async {
    final time = Time(8, 0 , 0);

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'memorare_quotidian', 'Quotidian from Memorare', 'Daily quote from Memorare',
      icon: 'memorare_icon',
      style: AndroidNotificationStyle.BigText,
    );

    final iOSPlatformChannelSpecifics = IOSNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics
    );

    final quotidian = await getSavedQuotidian();
    if (quotidian == null) { return; }

    await _plugin.showDailyAtTime(
      0,
      'Quotidian',
      '${quotidian.quote.name} - ${quotidian.quote.author.name}',
      time,
      platformChannelSpecifics,
      payload: quotidian.quote.id
    );
  }

  static Future<Quotidian> getSavedQuotidian() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/quotidian';
    final file = File(path);

    try {
      final str = file.readAsStringSync();
      final json = jsonDecode(str);
      final quotidian = Quotidian.fromJSON(json);

      return quotidian;

    } catch (e) {
      return null;
    }
  }
}
