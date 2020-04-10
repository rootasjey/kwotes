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
    icon: Icon(
      iconData,
      color: Colors.white,
    ),
    messageText: Text(
      message,
      overflow: TextOverflow.ellipsis,
      maxLines: 5,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  )..show(context);
}
