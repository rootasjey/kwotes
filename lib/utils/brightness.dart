import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:flutter/material.dart';

class BrightnessUtils {
  /// Refresh current theme with auto brightness.
  static void setAutoBrightness(BuildContext context) {
    final now = DateTime.now();

    Brightness brightness = Brightness.light;

    if (now.hour < 6 || now.hour > 17) {
      brightness = Brightness.dark;
    }

    if (brightness == Brightness.dark) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }

    stateColors.refreshTheme(brightness);
    appStorage.setAutoBrightness(true);
  }

  /// Refresh current theme with a specific brightness.
  static void setBrightness(BuildContext context, Brightness brightness) {
    if (brightness == Brightness.dark) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }

    stateColors.refreshTheme(brightness);
    appStorage.setAutoBrightness(false);
    appStorage.setBrightness(brightness);
  }
}
