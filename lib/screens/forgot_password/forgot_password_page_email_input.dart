import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class ForgotPasswordPageEmailInput extends StatelessWidget {
  const ForgotPasswordPageEmailInput({
    super.key,
    this.accentColor = Colors.amber,
    this.onEmailChanged,
    this.emailErrorMessage = "",
    required this.emailController,
  });

  /// Random accent color.
  final Color accentColor;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Error message about the email.
  final String emailErrorMessage;

  /// Input controller for the email.
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          autofocus: true,
          controller: emailController,
          onChanged: onEmailChanged,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
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
                width: 2.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.2) ??
                    Colors.white12,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: accentColor,
                width: 2.0,
              ),
            ),
          ),
        ),
        // emailCheckProgress(),
        if (emailErrorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              emailErrorMessage,
              style: TextStyle(
                color: Colors.red.shade300,
              ),
            ),
          ),
      ],
    );
  }
}
