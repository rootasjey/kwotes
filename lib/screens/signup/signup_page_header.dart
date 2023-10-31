import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class SignupPageHeader extends StatelessWidget {
  const SignupPageHeader({
    super.key,
    this.isMobileSize = false,
    this.randomColor = Colors.amber,
    this.onNavigateToSignin,
  });

  /// True if the screen's width is smaller than 600px.
  /// Back behavior is different if this is true.
  final bool isMobileSize;

  /// A random accent color.
  final Color randomColor;

  /// Callback fired to navigate to signin page.
  final void Function()? onNavigateToSignin;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Icon(
              TablerIcons.hammer,
              size: 42.0,
              color: randomColor,
            ),
          ),
          Text(
            "signup".tr(),
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
                onPressed: onNavigateToSignin,
                style: TextButton.styleFrom(
                  backgroundColor: randomColor.withOpacity(0.3),
                  foregroundColor: Colors.black,
                ),
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    "account.already_have".tr(),
                    style: Utils.calligraphy.code(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )),
          ),
        ].animate().slideY(begin: 0.8, end: 0.0).fadeIn(),
      ),
    );
  }
}
