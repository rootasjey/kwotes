import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class SignupPagePasswordInputs extends StatelessWidget {
  const SignupPagePasswordInputs({
    super.key,
    required this.confirmPasswordController,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    this.isMobileSize = false,
    this.randomColor = Colors.amber,
    this.onConfirmPasswordChanged,
    this.onPasswordChanged,
    this.onSubmit,
    this.confirmPasswordErrorMessage = "",
    this.confirmPasswordFocusNode,
  });

  /// Adapt user interface to the screen's size.
  /// True if the screen is small (e.g. <= 700 px).
  final bool isMobileSize;

  /// A random accent color.
  final Color randomColor;

  /// Used to focus confirm password input.
  final FocusNode? confirmPasswordFocusNode;

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
    const double inputWidth = 260.0;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 600.0,
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "password.name".tr(),
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: foregroundColor?.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isMobileSize ? null : inputWidth,
                      child: TextField(
                        autofocus: false,
                        controller: passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        onChanged: onPasswordChanged,
                        decoration: InputDecoration(
                          hintText: "•••••••••••",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: randomColor,
                              width: 4.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: foregroundColor?.withOpacity(0.4) ??
                                  Colors.white12,
                              width: 4.0,
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "password.confirm".tr(),
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: foregroundColor?.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isMobileSize ? null : inputWidth,
                      child: TextField(
                        autofocus: false,
                        controller: confirmPasswordController,
                        focusNode: confirmPasswordFocusNode,
                        obscureText: true,
                        textInputAction: TextInputAction.go,
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
                          hintText: "•••••••••••",
                          focusedBorder: OutlineInputBorder(
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
                        ),
                      ),
                    ),
                    if (confirmPasswordErrorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
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
        ].animate(delay: 75.ms).slideY(begin: 0.4, end: 0.0).fadeIn(),
      ),
    );
  }
}
