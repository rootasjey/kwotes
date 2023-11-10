import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class ForgotPasswordPageHeader extends StatelessWidget {
  const ForgotPasswordPageHeader({
    super.key,
    this.randomColor = Colors.amber,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
  });

  /// True if the screen's width is smaller than 600px.
  /// Back behavior is different if this is true.
  final bool isMobileSize;

  /// Random accent color.
  final Color randomColor;

  /// Spacing around this widget.
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: margin,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: Icon(
                TablerIcons.egg_cracked,
                size: 42.0,
                color: randomColor,
              ),
            ),
            Text(
              "password.forgot".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: isMobileSize ? 24.0 : 54.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Opacity(
              opacity: 0.4,
              child: Text(
                "password.forgot_reset_process".tr(),
                textAlign: TextAlign.center,
                style: Utils.calligraphy.body4(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ].animate().slideY(begin: 0.8, end: 0.0).fadeIn(),
        ),
      ),
    );
  }
}
