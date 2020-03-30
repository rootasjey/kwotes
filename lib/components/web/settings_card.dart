import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final String name;
  final Icon icon;
  final Function onTap;
  final Color color;
  final Color backgroundColor;
  final double iconOpacity;

  SettingsCard({
    this.backgroundColor,
    this.color,
    this.icon,
    this.iconOpacity = .6,
    this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: 190.0,
        height: 190.0,
        child: Card(
          elevation: 0,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            )
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Opacity(
                      opacity: iconOpacity,
                      child: icon,
                    ),
                  ),

                  Opacity(
                    opacity: .6,
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}
