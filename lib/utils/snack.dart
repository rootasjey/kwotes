import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/state/colors.dart';
import 'package:supercharged/supercharged.dart';

enum SnackType { error, info, success }

Future showSnack({
  BuildContext context,
  Function onTap,
  String message,
  String title,
  SnackType type,
}) {
  Color color;
  if (type == SnackType.error) { color = Colors.red; }
  else if (type == SnackType.success) { color =  Colors.green; }
  else { color = stateColors.softBackground; }

  IconData iconData;
  if (type == SnackType.error) { iconData = Icons.error; }
  else if (type == SnackType.success) { iconData = Icons.check_circle; }
  else { iconData = Icons.info; }

  return Flushbar(
    backgroundColor: color,
    duration: 5.seconds,
    icon: Icon(
      iconData,
      color: Colors.white,
    ),
    title: title,
    messageText: Text(
      message,
      overflow: TextOverflow.ellipsis,
      maxLines: 5,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    onTap: onTap,
  ).show(context);
}
