import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AppPageSettings extends StatefulWidget {
  @override
  _AppPageSettingsState createState() => _AppPageSettingsState();
}

class _AppPageSettingsState extends State<AppPageSettings> {
  Brightness brightness;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 40.0, left: 20.0),
                child: Text(
                  'Theme',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ),
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
                  Provider.of<ThemeColor>(context).updateBackground(brightness);
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
                  Provider.of<ThemeColor>(context).updateBackground(brightness);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
