import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/texts/outlined_text_field.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class UpdateEmailPageBody extends StatelessWidget {
  const UpdateEmailPageBody({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.passwordFocusNode,
    this.pageState = EnumPageState.idle,
    this.errorMessage = "",
    this.onEmailChanged,
    this.margin = EdgeInsets.zero,
    this.isMobileSize = false,
    this.onTapUpdateButton,
    this.onPasswordChanged,
    this.passwordErrorMessage = "",
    this.hintEmail = "",
  });

  /// True if the screen's size is narrow.
  final bool isMobileSize;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Email text controller.
  final TextEditingController emailController;

  /// Password text controller.
  final TextEditingController passwordController;

  /// Password focus node.
  final FocusNode? passwordFocusNode;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// On email input changed.
  final void Function(String value)? onEmailChanged;

  /// On password input changed.
  final void Function(String value)? onPasswordChanged;

  /// On email input changed.
  final void Function()? onTapUpdateButton;

  /// New email error message.
  final String errorMessage;

  /// Password rror message.
  final String passwordErrorMessage;

  /// Hint text for email input.
  final String hintEmail;

  @override
  Widget build(BuildContext context) {
    final Color secondaryHeaderColor = Theme.of(context).secondaryHeaderColor;

    return SliverToBoxAdapter(
      child: Padding(
        padding: isMobileSize
            ? const EdgeInsets.all(24.0)
            : const EdgeInsets.all(40.0),
        child: Column(
          children: [
            SizedBox(
              width: isMobileSize ? null : 352.0,
              child: Column(
                children: <Widget>[
                  OutlinedTextField(
                    autofocus: Utils.graphic.isMobile() ? false : true,
                    controller: emailController,
                    label: "email.new".tr(),
                    hintText: hintEmail,
                    keyboardType: TextInputType.text,
                    onChanged: onEmailChanged,
                    textInputAction: TextInputAction.next,
                  ),
                  Opacity(
                    opacity:
                        pageState == EnumPageState.checkingUsername ? 1.0 : 0.0,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: LinearProgressIndicator(),
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
            Container(
              padding: isMobileSize
                  ? const EdgeInsets.only(top: 0.0, bottom: 12.0)
                  : const EdgeInsets.only(top: 12.0, bottom: 12.0),
              width: isMobileSize ? null : 352.0,
              child: Column(
                children: [
                  OutlinedTextField(
                    autofocus: false,
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    label: "password.name".tr(),
                    keyboardType: TextInputType.text,
                    onChanged: onPasswordChanged,
                    textInputAction: TextInputAction.done,
                  ),
                  Opacity(
                    opacity: passwordErrorMessage.isEmpty ? 0.0 : 1.0,
                    child: Text(
                      passwordErrorMessage,
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
              onPressed: onTapUpdateButton,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
              ),
              child: SizedBox(
                width: 320.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    "email.update".tr().toUpperCase(),
                    softWrap: true,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]
              .animate(delay: 250.ms, interval: 50.ms)
              .fadeIn(duration: 150.ms, curve: Curves.decelerate)
              .slideY(begin: 0.4, end: 0.0),
        ),
      ),
    );
  }
}
