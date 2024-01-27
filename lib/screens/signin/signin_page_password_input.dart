import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/sufffix_button.dart";
import "package:kwotes/globals/utils.dart";

class SigninPagePasswordInput extends StatelessWidget {
  const SigninPagePasswordInput({
    super.key,
    required this.nameController,
    required this.passwordController,
    this.hidePassword = true,
    this.accentColor = Colors.amber,
    this.focusNode,
    this.onHidePasswordChanged,
    this.onPasswordChanged,
    this.onSubmit,
  });

  /// Hide password input if true.
  final bool hidePassword;

  /// Accent color.
  final Color accentColor;

  /// Used to focus the password input.
  final FocusNode? focusNode;

  /// Callback called when the user wants to hide/show password.
  final void Function(bool value)? onHidePasswordChanged;

  /// Callback fired when typed password changed.
  final void Function(String password)? onPasswordChanged;

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
        TextField(
          autofocus: false,
          obscureText: hidePassword,
          focusNode: focusNode,
          onChanged: onPasswordChanged,
          controller: passwordController,
          textInputAction: TextInputAction.go,
          keyboardType: TextInputType.visiblePassword,
          onSubmitted: (String password) => onSubmit?.call(
            nameController.text,
            password,
          ),
          decoration: InputDecoration(
            hintText: "•••••••••••",
            suffixIcon: SuffixButton(
              icon: Icon(hidePassword ? TablerIcons.eye : TablerIcons.eye_off),
              tooltipString:
                  hidePassword ? "password.show".tr() : "password.hide".tr(),
              onPressed: () => onHidePasswordChanged?.call(!hidePassword),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: accentColor,
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
      ]
          .animate(delay: 50.ms, interval: 25.ms)
          .slideY(
            begin: 0.8,
            end: 0.0,
            duration: const Duration(milliseconds: 100),
          )
          .fadeIn(),
    );
  }
}
