import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/sufffix_button.dart";
import "package:kwotes/components/texts/outlined_text_field.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class DeleteAccountPageBody extends StatelessWidget {
  const DeleteAccountPageBody({
    super.key,
    required this.passwordController,
    this.hidePassword = true,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.onHidePasswordChanged,
    this.onValidateDeletion,
    this.errorMessage = "",
    this.margin = const EdgeInsets.all(0.0),
  });

  /// Hide password input text if true.
  final bool hidePassword;

  /// True if the screen's size is narrow.
  final bool isMobileSize;

  /// Margin for the body.
  final EdgeInsets margin;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Called when the user wants to hide/show password.
  final void Function(bool value)? onHidePasswordChanged;

  /// Called when the delete button is pressed (or validate through pwd input).
  final void Function()? onValidateDeletion;

  /// Error message.
  final String errorMessage;

  /// Password text controller.
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final Color secondaryHeaderColor = Theme.of(context).secondaryHeaderColor;

    return SliverPadding(
      padding: margin,
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(isMobileSize ? 24.0 : 40.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                width: isMobileSize ? null : 352.0,
                child: Column(
                  children: <Widget>[
                    OutlinedTextField(
                      autofocus: Utils.graphic.isMobile() ? false : true,
                      obscureText: hidePassword,
                      controller: passwordController,
                      label: "password.confirm".tr(),
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => onValidateDeletion?.call(),
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
                    ),
                    Opacity(
                      opacity: errorMessage.isEmpty ? 0.0 : 1.0,
                      child: Text(
                        errorMessage,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            color: secondaryHeaderColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onValidateDeletion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  surfaceTintColor: Colors.pink,
                ),
                child: SizedBox(
                  width: 320.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 12.0,
                        ),
                        child: Text(
                          "delete.name".tr().toUpperCase(),
                          style: Utils.calligraphy.body(
                            textStyle: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
                .animate(delay: 250.ms, interval: 50.ms)
                .fadeIn(duration: 200.ms, curve: Curves.decelerate)
                .slideY(begin: 0.6, end: 0.0),
          ),
        ),
      ),
    );
  }
}
