import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({
    super.key,
    this.isMobileSize = false,
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverToBoxAdapter(
      child: Padding(
        padding: isMobileSize
            ? const EdgeInsets.only(top: 24.0, left: 24.0)
            : const EdgeInsets.only(
                top: 24.0,
                left: 48.0,
              ),
        child: Hero(
          tag: "settings",
          child: Material(
            color: Colors.transparent,
            child: Text.rich(
              TextSpan(text: "settings.name".tr(), children: [
                TextSpan(
                  text: ".",
                  style: TextStyle(
                    color: Constants.colors.settings,
                  ),
                ),
              ]),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: isMobileSize ? 16.0 : 26.0,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor?.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
