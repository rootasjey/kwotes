import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/dark_elevated_button.dart";
import "package:kwotes/components/fade_in_y.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:unicons/unicons.dart";

class ForgotPasswordPageBody extends StatelessWidget {
  const ForgotPasswordPageBody({
    super.key,
    required this.emailController,
    required this.emailErrorMessage,
    this.onCancel,
    this.onEmailChanged,
    this.onSubmit,
  });

  /// Callback fired to go back or exit this page.
  final void Function()? onCancel;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Callback fired when the user validate their information and want to signin.
  final void Function(String email)? onSubmit;

  /// Error message about the email.
  final String emailErrorMessage;

  /// Input controller for the email.
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          padding: const EdgeInsets.only(top: 40.0),
          width: 600.0,
          child: Column(children: [
            header(context),
            emailInput(context),
            footerButtons(context),
          ]),
        ),
      ),
    );
  }

  Widget emailInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInY(
          beginY: Utils.graphic.getBeginY(),
          delay: Duration(milliseconds: Utils.graphic.getNextAnimationDelay()),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 8.0,
              top: 16.0,
            ),
            child: Text(
              "email".tr(),
              style: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        FadeInY(
          beginY: Utils.graphic.getBeginY(),
          delay: Duration(milliseconds: Utils.graphic.getNextAnimationDelay()),
          child: TextField(
            autofocus: true,
            controller: emailController,
            onChanged: onEmailChanged,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "steven@universe.galaxy",
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Constants.colors.foregroundPalette.first,
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
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Constants.colors.foregroundPalette.first,
                  width: 4.0,
                ),
              ),
            ),
          ),
        ),
        // emailCheckProgress(),
        emailErrorMessageWidget(),
      ],
    );
  }

  Widget emailErrorMessageWidget() {
    if (emailErrorMessage.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        emailErrorMessage,
        style: TextStyle(
          color: Colors.red.shade300,
        ),
      ),
    );
  }

  Widget footerButtons(BuildContext context) {
    final Color randomAccentColor = Constants.colors.getRandomFromPalette();

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeInY(
            beginY: Utils.graphic.getBeginY(),
            delay:
                Duration(milliseconds: Utils.graphic.getNextAnimationDelay()),
            child: DarkElevatedButton.icon(
              elevation: 0.0,
              labelValue: "cancel".tr(),
              iconData: UniconsLine.times,
              background: randomAccentColor.withOpacity(0.4),
              foreground: Theme.of(context).textTheme.bodyMedium?.color,
              onPressed: () => onCancel?.call(),
              minimumSize: const Size(250.0, 60.0),
            ),
          ),
          FadeInY(
            beginY: Utils.graphic.getBeginY(),
            delay:
                Duration(milliseconds: Utils.graphic.getNextAnimationDelay()),
            child: DarkElevatedButton.large(
              onPressed: () {
                onSubmit?.call(emailController.text);
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "email.send_reset_link".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          color: randomAccentColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        UniconsLine.arrow_right,
                        color: randomAccentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget header(BuildContext context) {
    return Column(
      children: [
        FadeInY(
          beginY: Utils.graphic.getBeginY(),
          delay: Duration(
            milliseconds: Utils.graphic.getNextAnimationDelay(reset: true),
          ),
          child: Icon(
            TablerIcons.egg_cracked,
            size: 42.0,
            color: Constants.colors.foregroundPalette.first,
          ),
        ),
        FadeInY(
          beginY: Utils.graphic.getBeginY(),
          delay: Duration(
            milliseconds: Utils.graphic.getNextAnimationDelay(),
          ),
          child: Text(
            "password_forgot".tr(),
            style: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontSize: 42.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        FadeInY(
          beginY: Utils.graphic.getBeginY(),
          delay: Duration(
            milliseconds: Utils.graphic.getNextAnimationDelay(),
          ),
          child: Opacity(
            opacity: 0.4,
            child: Text(
              "password_forgot_reset_process".tr(),
              textAlign: TextAlign.center,
              style: Utils.calligraphy.body4(
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
