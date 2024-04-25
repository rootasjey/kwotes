import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class SigninPageEmailInput extends StatelessWidget {
  const SigninPageEmailInput({
    super.key,
    required this.emailController,
    this.accentColor = Colors.amber,
    this.margin = EdgeInsets.zero,
    this.borderWidth = 0.0,
    this.focusNode,
    this.onEmailChanged,
    this.borderRadius = BorderRadius.zero,
    this.labelText,
    this.hintText,
  });

  /// Border radius.
  final BorderRadius borderRadius;

  /// Accent color.
  final Color accentColor;

  /// Border width.
  final double borderWidth;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Used to focus the email input.
  final FocusNode? focusNode;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Text label for this input.
  final String? labelText;

  /// Text hint for this input.
  final String? hintText;

  /// Input controller for the name/email.
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: margin,
      child: TextField(
        autofocus: false,
        focusNode: focusNode,
        onChanged: onEmailChanged,
        controller: emailController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          isDense: true,
          labelText: labelText ?? "email.name".tr(),
          hintText: hintText ?? "steven@universe.galaxy",
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 12.0,
          ),
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: accentColor,
              width: borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: foregroundColor?.withOpacity(0.4) ?? Colors.white12,
              width: borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: accentColor,
              width: borderWidth,
            ),
          ),
        ),
      ),
    );
  }
}
