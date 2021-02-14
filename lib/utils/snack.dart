import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

Future showSnack({
  @required BuildContext context,
  String title = '',
  @required String message,
  SnackType type = SnackType.info,
}) {
  if (type == SnackType.error) {
    return FlashHelper.groundedBottom(
      context,
      title: title,
      message: message,
      icon: Icon(UniconsLine.times, color: Colors.pink),
    );
  } else if (type == SnackType.success) {
    return FlashHelper.groundedBottom(
      context,
      title: title,
      message: message,
      icon: Icon(UniconsLine.check, color: Colors.green),
    );
  }
  return FlashHelper.groundedBottom(
    context,
    title: title,
    message: message,
  );
}
