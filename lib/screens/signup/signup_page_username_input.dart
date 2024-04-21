import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class SignupPageUsernameInput extends StatelessWidget {
  const SignupPageUsernameInput({
    super.key,
    required this.usernameController,
    this.margin = EdgeInsets.zero,
    this.accentColor = Colors.amber,
    this.pageState = EnumPageState.idle,
    this.onUsernameChanged,
    this.usernameErrorMessage = "",
    this.focusNode,
  });

  /// A random accent color.
  final Color accentColor;

  /// Spacing around this widget.
  final EdgeInsets margin;

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
    const double borderWidth = 0.0;
    final BorderRadius borderRadius = BorderRadius.circular(36.0);
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            autofocus: true,
            controller: usernameController,
            focusNode: focusNode,
            onChanged: onUsernameChanged,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Steven",
              isDense: true,
              labelText: "username.name".tr(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
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
          if (pageState == EnumPageState.checkingUsername)
            LinearProgressIndicator(
              color: accentColor,
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
        ].animate(delay: 25.ms).slideY(begin: 0.2, end: 0.0).fadeIn(),
      ),
    );
  }
}
