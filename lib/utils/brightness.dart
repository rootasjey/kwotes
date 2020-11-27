import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Refresh current theme with auto brightness.
void setAutoBrightness(BuildContext context) {
  final now = DateTime.now();

  Brightness brightness = Brightness.light;

  if (now.hour < 6 || now.hour > 17) {
    brightness = Brightness.dark;
  }

  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    DynamicTheme.of(context).setBrightness(brightness);
    stateColors.refreshTheme(brightness);
    appStorage.setAutoBrightness(true);
  });
}

/// Refresh current theme with a specific brightness.
void setBrightness(BuildContext context, Brightness brightness) {
  stateColors.refreshTheme(brightness);

  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    DynamicTheme.of(context).setBrightness(brightness);

    appStorage.setAutoBrightness(false);
    appStorage.setBrightness(brightness);
  });
}
