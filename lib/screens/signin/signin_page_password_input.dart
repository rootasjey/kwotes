import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";

class SigninPagePasswordInput extends StatelessWidget {
  const SigninPagePasswordInput({
    super.key,
    required this.nameController,
    required this.passwordController,
    this.randomColor = Colors.amber,
    this.onSubmit,
    this.focusNode,
  });

  /// A random accent color.
  final Color randomColor;

  /// Used to focus the password input.
  final FocusNode? focusNode;

  /// Callback fired when the user validate their information and want to signin.
  final void Function(String name, String password)? onSubmit;

  /// Input controller for the name/email.
  final TextEditingController nameController;

  /// Input controller for the password.
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "password.name".tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.6),
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
            obscureText: true,
            focusNode: focusNode,
            controller: passwordController,
            textInputAction: TextInputAction.go,
            onSubmitted: (String password) => onSubmit?.call(
              nameController.text,
              password,
            ),
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
      ].animate(delay: 150.ms).slideY(begin: 0.8, end: 0.0).fadeIn(),
    );
  }
}
