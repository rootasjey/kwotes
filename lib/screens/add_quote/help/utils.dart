import 'package:flutter/material.dart';

class TextBlock extends StatelessWidget {
  final String text;

  TextBlock({this.text = ''});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17.0,
        ),
      ),
    );
  }
}
