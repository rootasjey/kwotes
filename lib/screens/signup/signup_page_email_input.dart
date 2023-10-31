import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
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
    final foregroundColor = Theme.of(context).textTheme.bodyMedium?.color;

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
              textStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: foregroundColor?.withOpacity(0.6),
              ),
            ),
          ),
        ),
        TextField(
          autofocus: false,
          controller: emailController,
          focusNode: focusNode,
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
                color: foregroundColor?.withOpacity(0.4) ?? Colors.white12,
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
