import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class SigninPageHeader extends StatelessWidget {
  const SigninPageHeader({
    super.key,
    this.isMobileSize = false,
    this.accentColor = Colors.amber,
    this.onNavigateToCreateAccount,
    this.margin = EdgeInsets.zero,
  });

  /// True if the screen's width is smaller than 600px.
  /// Back behavior is different if this is true.
  final bool isMobileSize;

  /// Accent color.
  final Color accentColor;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Callback fired to navigate to signup page.
  final void Function()? onNavigateToCreateAccount;

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
                TablerIcons.key,
                color: accentColor,
                size: 42.0,
              ),
            ),
            Text(
              "signin.name".tr(),
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
                  foregroundColor: accentColor,
                  backgroundColor: accentColor.withOpacity(0.05),
                ),
                child: Text(
                  "account.dont_own".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
