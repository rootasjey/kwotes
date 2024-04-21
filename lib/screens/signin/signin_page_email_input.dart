import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";

class SigninPageEmailInput extends StatelessWidget {
  const SigninPageEmailInput({
    super.key,
    required this.emailController,
    this.accentColor = Colors.amber,
    this.margin = EdgeInsets.zero,
    this.focusNode,
    this.onEmailChanged,
  });

  /// Accent color.
  final Color accentColor;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Used to focus the email input.
  final FocusNode? focusNode;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Input controller for the name/email.
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    const double borderWidth = 0.0;
    final BorderRadius borderRadius = BorderRadius.circular(36.0);

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
          // filled: true,
          isDense: true,
          // fillColor: Colors.white70,
          labelText: "email.name".tr(),
          hintText: "steven@universe.galaxy",
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
    )
        .animate(delay: 55.ms)
        .slideY(
          begin: 0.2,
          end: 0.0,
          // duration: const Duration(milliseconds: 100),
        )
        .fadeIn();
  }
}
