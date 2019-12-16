import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AppPageSettings extends StatefulWidget {
  @override
  _AppPageSettingsState createState() => _AppPageSettingsState();
}

class _AppPageSettingsState extends State<AppPageSettings> {
  Brightness _brightness;

  @override
  Widget build(BuildContext context) {
    _brightness = DynamicTheme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<ThemeColor>(context).accent,
        title: Text('App settings'),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 40.0, left: 20.0),
                child: Text(
                  'Theme',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ),
              RadioListTile(
                title: Text('Light'),
                value: Brightness.light,
                groupValue: _brightness,
                onChanged: (Brightness value) {
                  setState(() {
                    _brightness = value;
                  });

                  DynamicTheme.of(context).setBrightness(_brightness);
                  Provider.of<ThemeColor>(context).updateBackground(_brightness);
                },
              ),
              RadioListTile(
                title: Text('Dark'),
                value: Brightness.dark,
                groupValue: _brightness,
                onChanged: (Brightness value) {
                  setState(() {
                    _brightness = value;
                  });

                  DynamicTheme.of(context).setBrightness(_brightness);
                  Provider.of<ThemeColor>(context).updateBackground(_brightness);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
