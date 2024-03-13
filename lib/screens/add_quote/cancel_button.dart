import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class CancelButton extends StatelessWidget {
  /// A cancel button for input for add quote pages.
  const CancelButton({
    super.key,
    this.show = true,
    this.buttonStyle,
    this.onTapCancelButton,
    this.backgroundColor = Colors.transparent,
    this.focusNode,
    this.textStyle,
  });

  /// Show cancel button if true.
  final bool show;

  /// Button style.
  final ButtonStyle? buttonStyle;

  /// Button background color.
  final Color backgroundColor;

  /// Focus node for this button.
  final FocusNode? focusNode;

  /// Callback fired when this button is tapped.
  final void Function()? onTapCancelButton;

  /// Text style of the button.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextButton(
        focusNode: focusNode,
        onPressed: onTapCancelButton,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 0.0,
            horizontal: 8.0,
          ),
          backgroundColor: backgroundColor,
        ).merge(buttonStyle),
        child: Text(
          "cancel".tr(),
          style: Utils.calligraphy
              .body(
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              )
              .merge(textStyle),
        ),
      ),
    );
  }
}
