import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// Snack bar class.
/// Helper to quickly dispay different snacks types.
class Snack {
  /// Show a snack with an error message.
  static Future e({
    @required BuildContext context,
    Duration duration = const Duration(seconds: 5),
    Widget icon,
    @required String message,
    Widget primaryAction,
    String title = '',
  }) {
    Widget _icon;

    if (icon != null) {
      _icon = icon;
    } else {
      _icon = Icon(
        UniconsLine.times,
        color: Colors.pink,
      );
    }

    return FlashHelper.groundedBottom(
      context,
      title: title,
      message: message,
      icon: _icon,
      primaryAction: primaryAction,
    );
  }

  /// Show a snack with an informative message.
  static Future i({
    @required BuildContext context,
    Duration duration = const Duration(seconds: 5),
    Widget icon,
    @required String message,
    Widget primaryAction,
    String title = '',
  }) {
    Widget _icon;

    if (icon != null) {
      _icon = icon;
    } else {
      _icon = Icon(
        UniconsLine.info,
        color: Colors.blue,
      );
    }

    return FlashHelper.groundedBottom(
      context,
      title: title,
      message: message,
      icon: _icon,
      primaryAction: primaryAction,
    );
  }

  /// Show a snack with a success message.
  static Future s({
    @required BuildContext context,
    Duration duration = const Duration(seconds: 5),
    Widget icon,
    @required String message,
    Widget primaryAction,
    String title = '',
  }) {
    Widget _icon;

    if (icon != null) {
      _icon = icon;
    } else {
      _icon = Icon(
        UniconsLine.check,
        color: Colors.green,
      );
    }

    return FlashHelper.groundedBottom(
      context,
      title: title,
      message: message,
      icon: _icon,
      duration: duration,
      primaryAction: primaryAction,
    );
  }
}

Future showSnack({
  @required BuildContext context,
  String title = '',
  Widget icon,
  @required String message,
  SnackType type = SnackType.info,
  Widget primaryAction,
}) {
  if (type == SnackType.error) {
    return FlashHelper.groundedBottom(
      context,
      title: title,
      message: message,
      icon: icon != null
          ? icon
          : Icon(
              UniconsLine.times,
              color: Colors.pink,
            ),
      primaryAction: primaryAction,
    );
  } else if (type == SnackType.success) {
    return FlashHelper.groundedBottom(
      context,
      title: title,
      message: message,
      icon: icon != null
          ? icon
          : Icon(
              UniconsLine.check,
              color: Colors.green,
            ),
      primaryAction: primaryAction,
    );
  }
  return FlashHelper.groundedBottom(
    context,
    title: title,
    message: message,
    icon: icon,
    primaryAction: primaryAction,
  );
}
