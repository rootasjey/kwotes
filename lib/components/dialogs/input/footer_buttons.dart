import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class FooterButtons extends StatelessWidget {
  const FooterButtons({
    super.key,
    this.accentColor = Colors.blue,
    this.onSubmitted,
    this.submitButtonValue = "",
    this.nameController,
  });

  /// Accent color.
  final MaterialColor accentColor;

  /// Callback fired when input is submitted.
  final void Function(String value)? onSubmitted;

  /// Text value for the submit button.
  final String submitButtonValue;

  /// Controller for name input used here only because of the submit button.
  final TextEditingController? nameController;

  @override
  Widget build(BuildContext context) {
    final String textValue =
        submitButtonValue.isNotEmpty ? submitButtonValue : "create".tr();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TextButton(
        onPressed: () {
          final String value = nameController?.text ?? "";
          onSubmitted?.call(value);
        },
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          backgroundColor: accentColor.shade100,
          textStyle: Utils.calligraphy.body(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 16.0,
          ),
        ),
        child: Text(textValue),
      ),
      // child: DarkElevatedButton.large(
      //   onPressed: () {
      //     final String value = nameController?.text ?? "";
      //     onSubmitted.call(value);
      //   },
      //   child: Text(
      //     textValue,
      //     style: Utils.calligraphy.body(
      //       textStyle: const TextStyle(
      //         color: Colors.white,
      //         // color: Theme.of(context).textTheme.bodyMedium.color,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
