import 'package:flutter/material.dart';

class ErrorComponent extends StatelessWidget {
  final String description;

  ErrorComponent({this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(description),
      ],
    );
  }
}
