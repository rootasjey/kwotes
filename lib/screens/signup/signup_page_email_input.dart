import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class SignupPageEmailInput extends StatelessWidget {
  const SignupPageEmailInput({
    super.key,
    required this.emailController,
    this.randomColor = Colors.amber,
    this.pageState = EnumPageState.idle,
    this.onEmailChanged,
    this.emailErrorMessage = "",
    this.focusNode,
  });

  /// A random accent color.
  final Color randomColor;

  /// Page's state (e.g. idle, checking username, etc.).
  final EnumPageState pageState;

  /// Used to focus email input.
  final FocusNode? focusNode;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Error message about the email.
  final String emailErrorMessage;

  /// Input controller for the email.
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    const double borderWidth = 0.0;
    final BorderRadius borderRadius = BorderRadius.circular(36.0);
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          autofocus: false,
          controller: emailController,
          focusNode: focusNode,
          onChanged: onEmailChanged,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "email.name".tr(),
            hintText: "steven@universe.galaxy",
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: randomColor,
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
                color: randomColor,
                width: borderWidth,
              ),
            ),
          ),
        ),
        if (pageState == EnumPageState.checkingEmail)
          LinearProgressIndicator(
            color: randomColor,
          ),
        if (emailErrorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              emailErrorMessage,
              style: TextStyle(
                color: Constants.colors.error,
              ),
            ),
          )
      ].animate(delay: 50.ms).slideY(begin: 0.8, end: 0.0).fadeIn(),
    );
  }
}
