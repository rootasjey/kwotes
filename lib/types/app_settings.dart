import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppSettings {
  static bool isFirstLaunch = true;
  static bool isQuotidianNotifActive = true;

  static Future readFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/app_settings');

    try {
      final str = file.readAsStringSync();

      Map<String, dynamic> json = jsonDecode(str);

      if (json == null) { return; }

      isFirstLaunch = json['isFirstLaunch'];
      isQuotidianNotifActive = json['isQuotidianNotifActive'];

    } catch (e) {}
  }

  static Future saveToFile() async {
    final json = Map<String, dynamic>();
    json['isFirstLaunch'] = isFirstLaunch;
    json['isQuotidianNotifActive'] = isQuotidianNotifActive;

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/app_settings');

    final str = jsonEncode(json);
    await file.writeAsString(str);
  }

  static Future updateFirstLaunch(bool status) async {
    isFirstLaunch = status;

    await saveToFile();
  }

  static Future updateQuotidianNotifActive(bool status) async {
    isQuotidianNotifActive = status;

    await saveToFile();
  }
}
