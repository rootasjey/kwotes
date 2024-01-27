import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";

class SigninPageEmailInput extends StatelessWidget {
  const SigninPageEmailInput({
    super.key,
    required this.emailController,
    this.accentColor = Colors.amber,
    this.focusNode,
    this.onEmailChanged,
  });

  /// Accent color.
  final Color accentColor;

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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 42.0,
            bottom: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "email.name".tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: foregroundColor?.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 12.0,
          ),
          child: TextField(
            autofocus: false,
            focusNode: focusNode,
            onChanged: onEmailChanged,
            controller: emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "steven@universe.galaxy",
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: accentColor,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: foregroundColor?.withOpacity(0.4) ?? Colors.white12,
                  width: 4.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: accentColor,
                  width: 4.0,
                ),
              ),
            ),
          ),
        ),
      ]
          .animate(delay: 15.ms, interval: 25.ms)
          .slideY(
            begin: 0.8,
            end: 0.0,
            duration: const Duration(milliseconds: 100),
          )
          .fadeIn(),
    );
  }
}
