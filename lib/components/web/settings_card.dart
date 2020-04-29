import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final double elevation;
  final double iconOpacity;
  final String imagePath;
  final String name;
  final Function onTap;

  SettingsCard({
    this.elevation = 0,
    this.iconOpacity = .6,
    this.imagePath,
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
          elevation: elevation,
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
                      child: Image.asset(
                        imagePath,
                        width: 50.0,
                      ),
                    ),
                  ),

                  Opacity(
                    opacity: .6,
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
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
