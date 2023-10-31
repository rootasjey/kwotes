import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class SignupPageUsernameInput extends StatelessWidget {
  const SignupPageUsernameInput({
    super.key,
    required this.usernameController,
    this.randomColor = Colors.amber,
    this.pageState = EnumPageState.idle,
    this.onUsernameChanged,
    this.usernameErrorMessage = "",
    this.focusNode,
  });

  /// A random accent color.
  final Color randomColor;

  /// Page's state.
  final EnumPageState pageState;

  /// Used to focus username input.
  final FocusNode? focusNode;

  /// Callback fired when typed name changed.
  final void Function(String name)? onUsernameChanged;

  /// Error message about the username.
  final String usernameErrorMessage;

  /// Input controller for the username.
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 54.0,
            bottom: 8.0,
          ),
          child: Text(
            "username.name".tr(),
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
          autofocus: true,
          controller: usernameController,
          focusNode: focusNode,
          onChanged: onUsernameChanged,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "Steven",
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: randomColor,
                width: 2.0,
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
        if (pageState == EnumPageState.checkingUsername)
          LinearProgressIndicator(
            color: randomColor,
          ),
        if (usernameErrorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              usernameErrorMessage,
              style: TextStyle(
                color: Constants.colors.error,
              ),
            ),
          ),
      ].animate(delay: 25.ms).slideY(begin: 0.8, end: 0.0).fadeIn(),
    );
  }
}
