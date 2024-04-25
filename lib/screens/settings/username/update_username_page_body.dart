import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/outlined_text_field.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class UpdateUsernamePageBody extends StatelessWidget {
  const UpdateUsernamePageBody({
    super.key,
    required this.usernameController,
    required this.passwordFocusNode,
    required this.username,
    this.accentColor = Colors.amber,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.errorMessage = "",
    this.onUsernameChanged,
    this.onTapUpdateButton,
  });

  /// True if the screen's size is narrow.
  final bool isMobileSize;

  /// Accent color.
  final Color accentColor;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Password focus node.
  final FocusNode passwordFocusNode;

  /// On username input changed.
  final void Function(String value)? onUsernameChanged;

  /// On username input changed.
  final void Function()? onTapUpdateButton;

  /// Error message.
  final String errorMessage;

  /// Curernt username.
  final String username;

  /// Username text controller.
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    final Color secondaryHeaderColor = Theme.of(context).secondaryHeaderColor;

    if (pageState == EnumPageState.updatingUsername) {
      return LoadingView(
        message: "${"username.update.ing".tr()}...",
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        width: isMobileSize ? null : 360.0,
        padding: isMobileSize
            ? const EdgeInsets.all(24.0)
            : const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Container(
              width: isMobileSize ? null : 352.0,
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                children: <Widget>[
                  OutlinedTextField(
                    autofocus: Utils.graphic.isMobile() ? false : true,
                    controller: usernameController,
                    label: "username.new".tr(),
                    hintText: username,
                    keyboardType: TextInputType.text,
                    onChanged: onUsernameChanged,
                    textInputAction: TextInputAction.done,
                  ),
                  Opacity(
                    opacity:
                        pageState == EnumPageState.checkingUsername ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: LinearProgressIndicator(
                        color: accentColor,
                      ),
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
              onPressed: onTapUpdateButton,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 12.0,
                ),
                width: 320.0,
                child: Text(
                  "update.name".tr().toUpperCase(),
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
          ]
              .animate(delay: 250.ms, interval: 50.ms)
              .fadeIn(duration: 200.ms, curve: Curves.decelerate)
              .slideY(begin: 0.6, end: 0.0),
        ),
      ),
    );
  }
}
