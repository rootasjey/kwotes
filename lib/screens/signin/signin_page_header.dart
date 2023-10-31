import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class SigninPageHeader extends StatelessWidget {
  const SigninPageHeader({
    super.key,
    this.isMobileSize = false,
    this.randomColor = Colors.amber,
    this.onNavigateToCreateAccount,
  });

  /// True if the screen's width is smaller than 600px.
  /// Back behavior is different if this is true.
  final bool isMobileSize;

  /// A random accent color.
  final Color randomColor;

  /// Callback fired to navigate to signup page.
  final void Function()? onNavigateToCreateAccount;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Icon(
              TablerIcons.air_balloon,
              color: randomColor,
              size: 42.0,
            ),
          ),
          Text(
            "signin".tr(),
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: isMobileSize ? 24.0 : 54.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: TextButton(
              onPressed: onNavigateToCreateAccount,
              style: TextButton.styleFrom(
                backgroundColor: randomColor.withOpacity(0.1),
              ),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "account.dont_own".tr(),
                  style: Utils.calligraphy.code(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ].animate().slideY(begin: 0.8, end: 0.0).fadeIn(),
      ),
    );
  }
}
