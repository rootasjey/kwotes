import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final String name;
  final Icon icon;
  final Function onTap;

  SettingsCard({
    this.name,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: 220,
        height: 260.0,
        child: Card(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                      fontSize: 18.0,
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
