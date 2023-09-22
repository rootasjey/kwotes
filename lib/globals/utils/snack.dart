import "package:flutter/material.dart";
import "package:timer_snackbar/timer_snackbar.dart";

class Snack {
  static success(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    timerSnackbar(
        context: context,
        contentText: message,
        afterTimeExecute: () {},
        buttonLabel: "");
    // final SnackBar snackBar = SnackBar(
    //   elevation: 0,
    //   behavior: SnackBarBehavior.floating,
    //   backgroundColor: Colors.transparent,
    //   content: AwesomeSnackbarContent(
    //     title: title,
    //     message: message,
    //     contentType: ContentType.success,
    //   ),
    // );

    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static error(
    BuildContext context, {
    String title = "",
    required String message,
  }) {
    // final SnackBar snackBar = SnackBar(
    //   elevation: 0,
    //   behavior: SnackBarBehavior.floating,
    //   backgroundColor: Colors.transparent,
    //   content: AwesomeSnackbarContent(
    //     title: title,
    //     message: message,
    //     contentType: ContentType.failure,
    //   ),
    // );

    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
