import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/screens/settings/settings_item_data.dart";
import "package:url_launcher/url_launcher.dart";

class SettingsPageBody extends StatelessWidget {
  const SettingsPageBody({
    super.key,
    this.margin = EdgeInsets.zero,
  });

  /// Spacing around this widget.
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverPadding(
      padding: margin,
      sliver: SliverToBoxAdapter(
        child: Card(
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...[
                  SettingsItemData(
                    name: "theme.name".tr(),
                    route: SettingsContentLocation.themeRoute,
                  ),
                  SettingsItemData(
                    name: "language.name".tr(),
                    route: SettingsContentLocation.languageRoute,
                  ),
                  SettingsItemData(
                    name: "settings.ui".tr(),
                    route: SettingsContentLocation.userInterfaceRoute,
                  ),
                ].map(
                  (SettingsItemData settingsItemData) {
                    return ListTile(
                      onTap: () {
                        context.beamToNamed(settingsItemData.route);
                      },
                      title: Text(
                        settingsItemData.name,
                      ),
                      dense: true,
                      trailing: Icon(
                        TablerIcons.chevron_right,
                        size: 18.0,
                        color: foregroundColor?.withOpacity(0.6),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    );
                  },
                ).toList(),
                Divider(
                  color: foregroundColor?.withOpacity(0.1),
                  thickness: 1.5,
                ),
                // WaveDivider(color: foregroundColor?.withOpacity(0.6)),
                ...[
                  SettingsItemData(
                    name: "tos.name".tr(),
                    route: SettingsContentLocation.tosRoute,
                    isExternalLink: false,
                  ),
                  SettingsItemData(
                      name: "credits.name".tr(),
                      route: SettingsContentLocation.creditsRoute,
                      isExternalLink: false),
                  const SettingsItemData(
                    name: "GitHub",
                    route: Constants.githubUrl,
                    isExternalLink: true,
                  ),
                  SettingsItemData(
                    name: "about.us".tr(),
                    route: SettingsContentLocation.aboutUsRoute,
                    isExternalLink: false,
                  ),
                  SettingsItemData(
                    name: "contact.us".tr(),
                    route: SettingsContentLocation.feedbackRoute,
                    isExternalLink: false,
                  ),
                  SettingsItemData(
                    name: "changelog.name".tr(),
                    route: SettingsContentLocation.changelogRoute,
                    description:
                        "${"changelog.version".tr()}: ${Constants.appVersion}",
                    isExternalLink: false,
                  ),
                ].map(
                  (SettingsItemData settingsItemData) {
                    return ListTile(
                      onTap: () {
                        if (settingsItemData.isExternalLink) {
                          launchUrl(Uri.parse(settingsItemData.route));
                          return;
                        }

                        if (settingsItemData.route.isNotEmpty) {
                          context.beamToNamed(settingsItemData.route);
                        }
                      },
                      title: Text(
                        settingsItemData.name,
                      ),
                      subtitleTextStyle: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 10.0,
                          color: foregroundColor?.withOpacity(0.4),
                        ),
                      ),
                      subtitle: settingsItemData.description.isNotEmpty
                          ? Text(settingsItemData.description)
                          : null,
                      dense: true,
                      trailing: Icon(
                        settingsItemData.isExternalLink
                            ? TablerIcons.arrow_up_right
                            : TablerIcons.chevron_right,
                        size: 18.0,
                        color: foregroundColor?.withOpacity(0.6),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    );
                  },
                ).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
