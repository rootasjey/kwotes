import 'package:flutter/material.dart';

class SettingsColorCard extends StatelessWidget {
    final String name;
    final Icon icon;
    final Function onTap;
    final Color color;
    final Color backgroundColor;

  SettingsColorCard({
    this.name,
    this.icon,
    this.onTap,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: 200,
        height: 250.0,
        child: Card(
          color: backgroundColor,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Opacity(
                    opacity: .6,
                    child: icon,
                  ),
                ),

                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: color,
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
