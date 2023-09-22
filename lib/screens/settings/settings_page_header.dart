import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
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
                  fontSize: 26.0,
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
