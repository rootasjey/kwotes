import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  final Widget icon;
  final String subtitle;
  final String title;
  final Function onRefresh;

  EmptyContent({
    this.icon,
    this.onRefresh,
    this.subtitle,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: <Widget>[
          if (icon != null) icon,
          Opacity(
            opacity: 0.8,
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
            ),
          if (onRefresh != null)
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: onRefresh,
              ),
            ),
        ],
      ),
    );
  }
}
