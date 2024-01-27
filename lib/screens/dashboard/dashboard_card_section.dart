import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/screens/dashboard/dashboard_card.dart";

class DashboardCardSection extends StatelessWidget {
  /// A list of dashboard card widgets.
  const DashboardCardSection({
    super.key,
    this.isMobileSize = false,
    this.isDark = false,
  });

  /// True if the screen size is similar to a mobile.
  /// Adapt UI accordingly.
  final bool isMobileSize;

  /// True if the theme is dark.
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 36.0, left: 12.0, right: 12.0)
          : const EdgeInsets.only(top: 24.0, left: 48.0, right: 48.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          DashboardCard(
            compact: isMobileSize,
            iconData: TablerIcons.heart,
            isDark: isDark,
            hoverColor: Constants.colors.likes,
            textSubtitle: "favourites.description".tr(),
            textTitle: "favourites.name".tr(),
            heroKey: "favourites",
            onTap: () {
              context.beamToNamed(
                DashboardContentLocation.favouritesRoute,
              );
            },
          ),
          DashboardCard(
            compact: isMobileSize,
            hoverColor: Constants.colors.lists,
            iconData: TablerIcons.list,
            isDark: isDark,
            textSubtitle: "lists.description".tr(),
            textTitle: "lists.name".tr(),
            heroKey: "lists",
            onTap: () {
              context.beamToNamed(
                DashboardContentLocation.listsRoute,
              );
            },
          ),
          DashboardCard(
            compact: isMobileSize,
            hoverColor: Constants.colors.inValidation,
            iconData: TablerIcons.clock,
            isDark: isDark,
            textSubtitle: "in_validation.description".tr(),
            textTitle: "in_validation.name".tr(),
            heroKey: "in_validation",
            onTap: () {
              context.beamToNamed(
                DashboardContentLocation.inValidationRoute,
              );
            },
          ),
          DashboardCard(
            compact: isMobileSize,
            hoverColor: Constants.colors.published,
            iconData: TablerIcons.send,
            isDark: isDark,
            textSubtitle: "published.description".tr(),
            textTitle: "published.name".tr(),
            heroKey: "published",
            onTap: () {
              context.beamToNamed(
                DashboardContentLocation.publishedRoute,
              );
            },
          ),
          DashboardCard(
            compact: isMobileSize,
            hoverColor: Constants.colors.drafts,
            iconData: TablerIcons.note,
            isDark: isDark,
            textSubtitle: "drafts.description".tr(),
            textTitle: "drafts.name".tr(),
            heroKey: "drafts",
            onTap: () {
              context.beamToNamed(
                DashboardContentLocation.draftsRoute,
              );
            },
          ),
          DashboardCard(
            compact: isMobileSize,
            iconData: TablerIcons.settings,
            isDark: isDark,
            hoverColor: Constants.colors.settings,
            textSubtitle: "settings.description".tr(),
            textTitle: "settings.name".tr(),
            heroKey: "settings",
            onTap: () {
              context.beamToNamed(
                DashboardContentLocation.settingsRoute,
              );
            },
          ),
        ]
            .animate(interval: 25.ms)
            .fadeIn(duration: 200.ms, curve: Curves.decelerate)
            .slideY(begin: 0.2, end: 0.0),
      ),
    );
  }
}
