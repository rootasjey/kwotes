import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/sufffix_button.dart";

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
    const double borderWidth = 0.0;
    final BorderRadius borderRadius = BorderRadius.circular(36.0);

    return TextField(
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
        labelText: "password.name".tr(),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 12.0,
        ),
        suffixIcon: SuffixButton(
          icon: Icon(hidePassword ? TablerIcons.eye : TablerIcons.eye_off),
          tooltipString:
              hidePassword ? "password.show".tr() : "password.hide".tr(),
          onPressed: () => onHidePasswordChanged?.call(!hidePassword),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: accentColor,
            width: borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.4) ??
                Colors.white12,
            width: borderWidth,
          ),
        ),
      ),
    );
  }
}
