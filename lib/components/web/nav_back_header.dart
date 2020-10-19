import 'package:flutter/material.dart';
import 'package:memorare/components/app_icon.dart';

class NavBackHeader extends StatelessWidget {
  final Function onLongPress;

  NavBackHeader({
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final top = width < 500.0 ? 20.0 : 85.0;
    final left = width < 500.0 ? 30.0 : 80.0;

    return Stack(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            width < 500.0
                ? AppIcon(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 80.0,
                    ),
                  )
                : AppIcon(),
          ],
        ),
        Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onLongPress: onLongPress,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
      ],
    );
  }
}
