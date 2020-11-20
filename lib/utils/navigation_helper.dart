import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class NavigationHelper {
  static void navigateNextFrame(
    MaterialPageRoute pageRoute,
    BuildContext context,
  ) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Navigator.of(context).push(pageRoute);
    });
  }
}
