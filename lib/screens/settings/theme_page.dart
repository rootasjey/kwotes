import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/types/theme_settings_data.dart";

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdaptiveThemeMode currentTheme = AdaptiveTheme.of(context).mode;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SettingsPageHeader(
            isMobileSize: isMobileSize,
            onTapBackButton: context.beamBack,
            title: "theme.name".tr(),
          ),
          SliverPadding(
            padding: isMobileSize
                ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
                : const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                ThemeSettingsData(
                  selected: currentTheme == AdaptiveThemeMode.light,
                  title: "theme.light".tr(),
                  subtitle: "theme.light_description".tr(),
                  iconData: TablerIcons.sun,
                  onTap: () => AdaptiveTheme.of(context).setLight(),
                ),
                ThemeSettingsData(
                  selected: currentTheme == AdaptiveThemeMode.dark,
                  title: "theme.dark".tr(),
                  subtitle: "theme.dark_description".tr(),
                  iconData: TablerIcons.moon,
                  onTap: () => AdaptiveTheme.of(context).setDark(),
                ),
                ThemeSettingsData(
                  selected: currentTheme == AdaptiveThemeMode.system,
                  title: "theme.system".tr(),
                  subtitle: "theme.system_description".tr(),
                  iconData: TablerIcons.brightness,
                  onTap: () => AdaptiveTheme.of(context).setSystem(),
                ),
              ]
                  .map(
                    (ThemeSettingsData data) => ListTile(
                      selected: data.selected,
                      onTap: data.onTap,
                      title: Text(data.title),
                      subtitle: Text(data.subtitle),
                      iconColor: data.selected
                          ? Theme.of(context).primaryColor
                          : foregroundColor?.withOpacity(0.6),
                      subtitleTextStyle: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 10.0,
                          color: foregroundColor?.withOpacity(0.4),
                        ),
                      ),
                      dense: true,
                      trailing: Icon(
                        data.iconData,
                        size: 18.0,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  )
                  .toList()),
            ),
          ),
        ],
      ),
    );
  }
}
