import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/password_checks.dart";

class UpdatePasswordPageHeader extends StatelessWidget {
  const UpdatePasswordPageHeader({
    super.key,
    required this.passwordChecks,
    this.isMobileSize = false,
    this.accentColor,
    this.margin = EdgeInsets.zero,
    this.onTapLeftPartHeader,
    this.onTapRemindMe,
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Accent color.
  final Color? accentColor;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when left part header is tapped.
  final void Function()? onTapLeftPartHeader;

  /// Callback fired when "remind me" button is tapped.
  final void Function()? onTapRemindMe;

  /// Indicates if all requirements for the new password are met.
  final PasswordChecks passwordChecks;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverPadding(
      padding: margin,
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: isMobileSize
              ? const EdgeInsets.only(top: 0.0, left: 24.0, right: 24.0)
              : const EdgeInsets.only(top: 72.0),
          child: Column(
            crossAxisAlignment: isMobileSize
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: FractionallySizedBox(
                  widthFactor: isMobileSize ? 0.9 : 0.4,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "password.update.tips.minimum_length"
                              .tr(args: ["6"]),
                          style: TextStyle(
                            color: passwordChecks.hasMinimumLength
                                ? Constants.colors.foregroundPalette.first
                                : null,
                            fontWeight: passwordChecks.hasMinimumLength
                                ? FontWeight.w800
                                : null,
                          ),
                        ),
                        const TextSpan(text: ", "),
                        TextSpan(
                          text: "password.update.tips.lower_case".tr(),
                          children: const [TextSpan(text: ", ")],
                          style: TextStyle(
                            color: passwordChecks.hasLowercase
                                ? Constants.colors.foregroundPalette
                                    .elementAt(1)
                                : null,
                            fontWeight: passwordChecks.hasLowercase
                                ? FontWeight.w800
                                : null,
                          ),
                        ),
                        TextSpan(
                          text: "password.update.tips.upper_case".tr(),
                          children: const [TextSpan(text: ", ")],
                          style: TextStyle(
                            color: passwordChecks.hasUppercase
                                ? Constants.colors.foregroundPalette
                                    .elementAt(2)
                                : null,
                            fontWeight: passwordChecks.hasUppercase
                                ? FontWeight.w800
                                : null,
                          ),
                        ),
                        TextSpan(
                          text: "password.update.tips.and".tr(),
                          children: const [TextSpan(text: " ")],
                        ),
                        TextSpan(
                          text: "password.update.tips.number".tr(),
                          children: const [TextSpan(text: ".")],
                          style: TextStyle(
                            color: passwordChecks.hasDigit
                                ? Constants.colors.foregroundPalette
                                    .elementAt(3)
                                : null,
                            fontWeight: passwordChecks.hasDigit
                                ? FontWeight.w600
                                : null,
                          ),
                        ),
                      ],
                    ),
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 14.0,
                        color: foregroundColor?.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ]
                .animate(interval: 50.ms)
                .fadeIn(duration: 200.ms, curve: Curves.decelerate)
                .slideY(begin: 0.4, end: 0.0),
          ),
        ),
      ),
    );
  }
}
