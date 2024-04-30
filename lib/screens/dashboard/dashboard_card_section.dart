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
            hoverColor: Constants.colors.premium,
            iconData: TablerIcons.crown,
            isDark: isDark,
            textSubtitle: "premium.super_powers".tr(),
            textTitle: "premium.name".tr(),
            heroKey: "premium",
            onTap: () {
              context.beamToNamed(
                DashboardContentLocation.myQuotesRoute,
              );
            },
          ),
          DashboardCard(
            compact: isMobileSize,
            hoverColor: Constants.colors.inValidation,
            iconData: TablerIcons.note,
            isDark: isDark,
            textSubtitle: "my_quotes.description".tr(),
            textTitle: "my_quotes.name".tr(),
            heroKey: "my_quotes",
            onTap: () {
              context.beamToNamed(
                DashboardContentLocation.myQuotesRoute,
              );
            },
          ),
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
        ]
            .animate(interval: 25.ms)
            .fadeIn(duration: 200.ms, curve: Curves.decelerate)
            .slideY(begin: 0.2, end: 0.0),
      ),
    );
  }
}
