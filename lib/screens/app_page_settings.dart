import 'dart:async';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:memorare/app_notifications.dart';
import 'package:memorare/types/app_settings.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AppPageSettings extends StatefulWidget {
  @override
  _AppPageSettingsState createState() => _AppPageSettingsState();
}

class _AppPageSettingsState extends State<AppPageSettings> {
  Brightness brightness;
  Timer timer;
  bool isDailyQuoteActive = true;

  @override
  initState() {
    super.initState();
    isDailyQuoteActive = AppSettings.isQuotidianNotifActive;
  }

  @override
  Widget build(BuildContext context) {
    brightness = DynamicTheme.of(context).brightness;
    final accent = Provider.of<ThemeColor>(context).accent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'App settings',
          style: TextStyle(
            color: accent,
            fontSize: 30.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: accent,),
        ),
      ),
      body: ListView(
        children: <Widget>[
          content(),
        ],
      ),
    );
  }

  Widget content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        themeSection(),
        backgroundTaskSection(),
      ],
    );
  }

  Widget themeSection() {
    final accent = Provider.of<ThemeColor>(context).accent;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 20.0, left: 20.0),
              child: Text(
                'Theme',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
          ],
        ),
        RadioListTile(
          activeColor: accent,
          title: Text(
            'Light',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          value: Brightness.light,
          groupValue: brightness,
          onChanged: (Brightness value) {
            setState(() {
              brightness = value;
            });

            DynamicTheme.of(context).setBrightness(brightness);
            Provider.of<ThemeColor>(context, listen: false).updateBackground(brightness);
          },
        ),
        RadioListTile(
          activeColor: accent,
          title: Text(
            'Dark',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          value: Brightness.dark,
          groupValue: brightness,
          onChanged: (Brightness value) {
            setState(() {
              brightness = value;
            });

            DynamicTheme.of(context).setBrightness(brightness);
            Provider.of<ThemeColor>(context, listen: false).updateBackground(brightness);
          },
        ),
      ],
    );
  }

  Widget backgroundTaskSection() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, bottom: 20.0, left: 20.0),
              child: Text(
                'Notifications',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
          ],
        ),

        SwitchListTile(
          onChanged: (bool value) {
            setState(() {
              isDailyQuoteActive = value;
            });

            timer?.cancel();
            timer = Timer(
              Duration(seconds: 1), () {
                AppSettings.updateQuotidianNotifActive(value);

                toggleBackgroundTask();
              });
          },
          value: isDailyQuoteActive,
          title: Text('Daily quote'),
          secondary: isDailyQuoteActive ?
            Icon(Icons.notifications_active):
            Icon(Icons.notifications_off),
        ),
      ],
    );
  }

  void toggleBackgroundTask() {
    if (isDailyQuoteActive == false) {
      AppNotifications.plugin.cancelAll();
      return;
    }
  }
}
