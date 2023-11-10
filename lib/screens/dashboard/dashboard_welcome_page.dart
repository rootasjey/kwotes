import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/dashboard/dashboard_card.dart";
import "package:kwotes/screens/dashboard/dashboard_fab.dart";
import "package:kwotes/screens/signin/signin_page.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:unicons/unicons.dart";

class DashboardWelcomePage extends StatelessWidget {
  const DashboardWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color randomColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );

    final UserFirestore userFirestore =
        context.observe<UserFirestore>(EnumSignalId.userFirestore);

    if (userFirestore.id.isEmpty) {
      return const SigninPage();
    }

    return SafeArea(
      child: Scaffold(
        floatingActionButton: DashboardFab(
          isMobileSize: isMobileSize,
          onGoToAddQuotePage: onGoToAddQuotePage,
          randomColor: randomColor,
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                const Align(
                  alignment: Alignment.topLeft,
                  child: AppIcon(
                    margin: EdgeInsets.only(top: 24.0, left: 12.0),
                  ),
                ),
                Padding(
                    padding: isMobileSize
                        ? const EdgeInsets.only(top: 12.0, left: 24.0)
                        : const EdgeInsets.only(
                            top: 12.0,
                            left: 48.0,
                          ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${"welcome_back".tr()},",
                            style: TextStyle(
                              color: foregroundColor?.withOpacity(0.4),
                              fontWeight: FontWeight.w100,
                              fontSize: isMobileSize ? 16.0 : 24.0,
                            ),
                          ),
                          TextSpan(
                            text: "\n${userFirestore.name}",
                            style: TextStyle(
                              color: foregroundColor?.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ".",
                            style: Utils.calligraphy.title(
                              textStyle: TextStyle(
                                color: randomColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: Utils.calligraphy.title(
                        textStyle: TextStyle(
                          fontSize: isMobileSize ? 42.0 : 54.0,
                          height: 1.0,
                        ),
                      ),
                    )),
                Padding(
                  padding: isMobileSize
                      ? const EdgeInsets.only(
                          top: 36.0,
                          left: 12.0,
                          right: 12.0,
                          bottom: 192.0,
                        )
                      : const EdgeInsets.only(
                          top: 24.0,
                          left: 48.0,
                          right: 48.0,
                          bottom: 92.0,
                        ),
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      DashboardCard(
                        compact: isMobileSize,
                        iconData: UniconsLine.heart,
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
                        iconData: UniconsLine.list_ul,
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
                        iconData: UniconsLine.clock,
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
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to the add/edit quote page.
  void onGoToAddQuotePage(BuildContext context) {
    NavigationStateHelper.quote = Quote.empty();
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }
}
