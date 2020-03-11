import 'package:flutter/material.dart';

class LoadingAnimation extends StatelessWidget {
  final String title;

  LoadingAnimation({this.title = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            CircularProgressIndicator(),

            Positioned(
              top: 5.0,
              left: 5.0,
              child: Image(
                image: AssetImage('assets/images/icon-30.png'),
                width: 25.0,
                height: 25.0,
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 40.0,
            ),
          ),
        ),
      ],
    );
  }
}
