import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/utils/router.dart';

class NavBackHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppIconHeader(),
          ],
        ),

        Positioned(
          left: 80.0,
          top: 100.0,
          child: IconButton(
            onPressed: () {
              FluroRouter.router.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
      ],
    );
  }
}
