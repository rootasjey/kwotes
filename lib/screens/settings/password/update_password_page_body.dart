import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/texts/outlined_text_field.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class UpdatePasswordPageBody extends StatelessWidget {
  const UpdatePasswordPageBody({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    this.isMobileSize = false,
    this.newPasswordFocusNode,
    this.pageState = EnumPageState.idle,
    this.onCurrentPasswordChanged,
    this.onNewPasswordChanged,
    this.onTapUpdateButton,
    this.currentPasswordErrorMessage = "",
    this.newPasswordErrorMessage = "",
  });

  /// True if the screen's size is narrow.
  final bool isMobileSize;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Password focus node.
  final FocusNode? newPasswordFocusNode;

  /// On email input changed.
  final void Function(String value)? onCurrentPasswordChanged;

  /// On password input changed.
  final void Function(String value)? onNewPasswordChanged;

  /// On email input changed.
  final void Function()? onTapUpdateButton;

  /// New email error message.
  final String currentPasswordErrorMessage;

  /// Password rror message.
  final String newPasswordErrorMessage;

  /// Email text controller.
  final TextEditingController currentPasswordController;

  /// Password text controller.
  final TextEditingController newPasswordController;

  @override
  Widget build(BuildContext context) {
    final Color secondaryHeaderColor = Theme.of(context).secondaryHeaderColor;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(isMobileSize ? 24.0 : 40.0),
        child: Column(
          children: [
            SizedBox(
              width: isMobileSize ? null : 352.0,
              child: Column(
                children: <Widget>[
                  OutlinedTextField(
                    autofocus: Utils.graphic.isMobile() ? false : true,
                    controller: currentPasswordController,
                    label: "password.current".tr(),
                    keyboardType: TextInputType.text,
                    onChanged: onCurrentPasswordChanged,
                    textInputAction: TextInputAction.next,
                  ),
                  Padding(
                    padding: currentPasswordErrorMessage.isEmpty
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(bottom: 6.0),
                    child: Opacity(
                      opacity: currentPasswordErrorMessage.isEmpty ? 0.0 : 1.0,
                      child: Text(
                        currentPasswordErrorMessage,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            color: secondaryHeaderColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 12.0),
              width: isMobileSize ? null : 352.0,
              child: Column(
                children: [
                  OutlinedTextField(
                    autofocus: false,
                    controller: newPasswordController,
                    focusNode: newPasswordFocusNode,
                    label: "password.new".tr(),
                    keyboardType: TextInputType.text,
                    onChanged: onNewPasswordChanged,
                    textInputAction: TextInputAction.done,
                  ),
                  Opacity(
                    opacity: newPasswordErrorMessage.isEmpty ? 0.0 : 1.0,
                    child: Text(
                      newPasswordErrorMessage,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Container(
                width: 320.0,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 14.0,
                ),
                child: Text(
                  "password.update.name".tr().toUpperCase(),
                  textAlign: TextAlign.center,
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
          ]
              .animate(delay: 250.ms, interval: 50.ms)
              .fadeIn(duration: 150.ms, curve: Curves.decelerate)
              .slideY(begin: 0.4, end: 0.0),
        ),
      ),
    );
  }
}
