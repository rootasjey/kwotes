import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

enum SnackType { error, success }

void showSnack({BuildContext context, String message, SnackType type}) {
  Color color = type == SnackType.error ? Colors.red : Colors.green;
  IconData iconData = type == SnackType.error ? Icons.error : Icons.check_circle;

  Flushbar(
    backgroundColor: color,
    duration: 5.seconds,
    messageText: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Icon(
            iconData,
            color: Colors.white,
          ),
        ),

        Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    ),
  )..show(context);
}
