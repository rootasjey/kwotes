import 'package:flutter/material.dart';
import 'package:memorare/types/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ButtonLink extends StatelessWidget {
  final Icon icon;
  final String text;
  final EdgeInsets padding;
  final String url;

  ButtonLink({
    this.icon,
    this.padding = const EdgeInsets.all(0.0),
    this.text,
    this.url
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: FlatButton(
        onPressed: () async {
          if (await canLaunch(url)) {
            await launch(url);
            return;
          }

          Scaffold.of(context)
            .showSnackBar(
              SnackBar(
                backgroundColor: ThemeColor.error,
                content: Text(
                  'Could not launch $url',
                  style: TextStyle(color: Colors.white),
                ),
              )
            );
        },
        color: ThemeColor.primary,
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: icon,
                ),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
