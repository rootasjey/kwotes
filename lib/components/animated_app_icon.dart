import 'package:flutter/material.dart';

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
            Padding(
              padding: const EdgeInsets.only(
                bottom: 0.0,
              ),
              child: Image.asset(
                'assets/images/app-icon-animation.gif',
                height: 100.0,
                width: 100.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
