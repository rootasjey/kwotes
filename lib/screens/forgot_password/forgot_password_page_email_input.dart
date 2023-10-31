import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class ForgotPasswordPageEmailInput extends StatelessWidget {
  const ForgotPasswordPageEmailInput({
    super.key,
    this.randomColor = Colors.amber,
    this.onEmailChanged,
    this.emailErrorMessage = "",
    required this.emailController,
  });

  /// Random accent color.
  final Color randomColor;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Error message about the email.
  final String emailErrorMessage;

  /// Input controller for the email.
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8.0,
            top: 16.0,
          ),
          child: Text(
            "email.name".tr(),
            style: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        TextField(
          autofocus: true,
          controller: emailController,
          onChanged: onEmailChanged,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "steven@universe.galaxy",
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: randomColor,
                width: 4.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.4) ??
                    Colors.white12,
                width: 4.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: randomColor,
                width: 4.0,
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
