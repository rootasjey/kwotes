import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/flash_helper.dart';
import 'package:flutter/material.dart';

Future showSnack({
  BuildContext context,
  String message,
  SnackType type,
}) {
  if (type == SnackType.error) {
    return FlashHelper.errorBar(context, message: message);
  } else if (type == SnackType.success) {
    return FlashHelper.successBar(context, message: message);
  }

  return FlashHelper.infoBar(context, message: message);
}
