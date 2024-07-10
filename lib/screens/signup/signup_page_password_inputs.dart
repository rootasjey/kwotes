import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/sufffix_button.dart";
import "package:kwotes/globals/constants.dart";

class SignupPagePasswordInputs extends StatelessWidget {
  const SignupPagePasswordInputs({
    super.key,
    required this.confirmPasswordController,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    this.isMobileSize = false,
    this.hidePassword = true,
    this.randomColor = Colors.amber,
    this.onConfirmPasswordChanged,
    this.onHidePasswordChanged,
    this.onPasswordChanged,
    this.onSubmit,
    this.confirmPasswordErrorMessage = "",
    this.confirmPasswordFocusNode,
  });

  /// Hide password input if true.
  final bool hidePassword;

  /// Adapt user interface to the screen's size.
  /// True if the screen is small (e.g. <= 700 px).
  final bool isMobileSize;

  /// A random accent color.
  final Color randomColor;

  /// Used to focus confirm password input.
  final FocusNode? confirmPasswordFocusNode;

  /// Callback called when the user wants to hide/show password.
  final void Function(bool value)? onHidePasswordChanged;

  /// Callback fired when typed confirm password changed.
  final void Function(
    String password,
    String confirmPassword,
  )? onConfirmPasswordChanged;

  /// Callback fired when typed password changed.
  final void Function(String password)? onPasswordChanged;

  /// Callback fired when the user validate their information and want to signin.
  final void Function(
    String name,
    String email,
    String password,
    String confirmPassword,
  )? onSubmit;

  /// Error message about the confirm password input.
  final String confirmPasswordErrorMessage;

  /// Input controller for the confirm password.
  final TextEditingController confirmPasswordController;

  /// Input controller for the email.
  final TextEditingController emailController;

  /// Input controller for the username.
  final TextEditingController usernameController;

  /// Input controller for the password.
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    const double borderWidth = 0.0;
    final BorderRadius borderRadius = BorderRadius.circular(36.0);
    const double inputWidth = 260.0;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    const EdgeInsets contentPadding = EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 16.0,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 600.0,
            child: Wrap(
              spacing: 24.0,
              runSpacing: 24.0,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: isMobileSize ? null : inputWidth,
                      child: TextField(
                        autofocus: false,
                        controller: passwordController,
                        obscureText: hidePassword,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: onPasswordChanged,
                        decoration: InputDecoration(
                          hintText: "•••••••••••",
                          labelText: "password.name".tr(),
                          contentPadding: contentPadding,
                          suffixIcon: SuffixButton(
                            icon: Icon(hidePassword
                                ? TablerIcons.eye
                                : TablerIcons.eye_off),
                            tooltipString: hidePassword
                                ? "password.show".tr()
                                : "password.hide".tr(),
                            onPressed: () =>
                                onHidePasswordChanged?.call(!hidePassword),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: randomColor,
                              width: borderWidth,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: foregroundColor?.withOpacity(0.4) ??
                                  Colors.white12,
                              width: borderWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: isMobileSize ? null : inputWidth,
                      child: TextField(
                        autofocus: false,
                        controller: confirmPasswordController,
                        focusNode: confirmPasswordFocusNode,
                        obscureText: hidePassword,
                        textInputAction: TextInputAction.go,
                        keyboardType: TextInputType.visiblePassword,
                        onSubmitted: (String confirmPassword) {
                          onSubmit?.call(
                            usernameController.text,
                            emailController.text,
                            passwordController.text,
                            confirmPassword,
                          );
                        },
                        onChanged: (String confirmPassword) {
                          onConfirmPasswordChanged?.call(
                            passwordController.text,
                            confirmPassword,
                          );
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: "•••••••••••",
                          labelText: "password.confirm".tr(),
                          contentPadding: contentPadding,
                          suffixIcon: SuffixButton(
                            icon: Icon(
                              hidePassword
                                  ? TablerIcons.eye
                                  : TablerIcons.eye_off,
                              size: 24.0,
                            ),
                            tooltipString: hidePassword
                                ? "password.show".tr()
                                : "password.hide".tr(),
                            onPressed: () =>
                                onHidePasswordChanged?.call(!hidePassword),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: randomColor,
                              width: borderWidth,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: foregroundColor?.withOpacity(0.4) ??
                                  Colors.white12,
                              width: borderWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (confirmPasswordErrorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.only(top: 8.0),
                        width: isMobileSize ? null : inputWidth,
                        child: Text(
                          confirmPasswordErrorMessage,
                          style: TextStyle(
                            color: Constants.colors.error,
                          ),
                        ),
                      ).animate().fade(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
