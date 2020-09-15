import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';

class AnimatedAppIcon extends StatelessWidget {
  final double size;

  AnimatedAppIcon({this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          children: [
            AppIconHeader(
              padding: const EdgeInsets.only(
                bottom: 20.0,
              ),
            ),

            LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
