import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class UsernamePageHeader extends StatelessWidget {
  const UsernamePageHeader({
    super.key,
    this.margin = EdgeInsets.zero,
    this.onTapLeftPartHeader,
  });

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when left part header is tapped.
  final void Function()? onTapLeftPartHeader;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverToBoxAdapter(
      child: Padding(
        // padding: margin,
        padding: const EdgeInsets.only(
          top: 42.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: "${"settings.name".tr()}: ",
                children: [
                  TextSpan(
                      text: "username.name".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          color: Constants.colors.getRandomFromPalette(),
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
            FractionallySizedBox(
              widthFactor: 0.6,
              child: Text(
                "username.update.tips".tr(),
                textAlign: TextAlign.center,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    color: foregroundColor?.withOpacity(0.4),
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
