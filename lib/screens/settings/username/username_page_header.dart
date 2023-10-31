import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class UsernamePageHeader extends StatelessWidget {
  const UsernamePageHeader({
    super.key,
    this.isMobileSize = false,
    this.onTapLeftPartHeader,
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Callback fired when left part header is tapped.
  final void Function()? onTapLeftPartHeader;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverToBoxAdapter(
      child: Padding(
        padding: isMobileSize
            ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
            : const EdgeInsets.only(top: 42.0),
        child: Column(
          crossAxisAlignment: isMobileSize
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: "${"settings.name".tr()}: ",
                children: [
                  TextSpan(
                      text: isMobileSize
                          ? "\n${"username.name".tr()}"
                          : "username.name".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          color: Constants.colors.getRandomFromPalette(
                            withGoodContrast: true,
                          ),
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ],
                recognizer: TapGestureRecognizer()..onTap = onTapLeftPartHeader,
              ),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w400,
                  color: foregroundColor?.withOpacity(0.6),
                ),
              ),
            ),
            Padding(
              padding: isMobileSize
                  ? const EdgeInsets.only(top: 8.0)
                  : EdgeInsets.zero,
              child: FractionallySizedBox(
                widthFactor: isMobileSize ? 0.9 : 0.6,
                child: Text(
                  "username.update.tips".tr(),
                  textAlign: isMobileSize ? TextAlign.left : TextAlign.center,
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      color: foregroundColor?.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          ]
              .animate(interval: 50.ms)
              .fadeIn(duration: 200.ms, curve: Curves.decelerate)
              .slideY(begin: 0.4, end: 0.0, duration: 250.ms),
        ),
      ),
    );
  }
}
