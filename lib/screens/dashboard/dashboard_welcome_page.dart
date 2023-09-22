import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/dashboard/dashboard_card.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:unicons/unicons.dart";

class DashboardWelcomePage extends StatelessWidget {
  const DashboardWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Topic randomTopic = Constants.colors.getRandomTopic();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        elevation: 0.0,
        hoverElevation: 4.0,
        focusElevation: 0.0,
        highlightElevation: 0.0,
        splashColor: Colors.white,
        onPressed: () => goToAddQuotePage(context),
        backgroundColor: randomTopic.color,
        icon: const Icon(TablerIcons.quote),
        foregroundColor: randomTopic.color.computeLuminance() > 0.4
            ? Colors.black
            : Colors.white,
        label: Text(
          "quote.add.a".tr(),
          style: Utils.calligraphy.body(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          const ApplicationBar(),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 48.0,
                ),
                child: SignalBuilder(
                  signal: userFirestoreSignal,
                  builder: (
                    BuildContext context,
                    UserFirestore userFirestore,
                    Widget? child,
                  ) {
                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${"welcome_back".tr()},",
                            style: TextStyle(
                              color: foregroundColor?.withOpacity(0.5),
                              fontWeight: FontWeight.w100,
                              fontSize: 24.0,
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
                                color: randomTopic.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: Utils.calligraphy.title(
                        textStyle: const TextStyle(
                          fontSize: 54.0,
                          height: 1.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                  left: 48.0,
                  bottom: 92.0,
                ),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    DashboardCard(
                      elevation: 0.0,
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
                      elevation: 0.0,
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
                      elevation: 0.0,
                      hoverColor: Constants.colors.inValidation,
                      iconData: UniconsLine.clock,
                      textSubtitle: "in_validation.description".tr(),
                      textTitle: "in_validation.name".tr(),
                      heroKey: "inValidation",
                      onTap: () {
                        context.beamToNamed(
                          DashboardContentLocation.inValidationRoute,
                        );
                      },
                    ),
                    DashboardCard(
                      elevation: 0.0,
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
                      elevation: 0.0,
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
                      elevation: 0.0,
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
                      .animate(interval: 75.ms)
                      .fadeIn(duration: 200.ms, curve: Curves.decelerate)
                      .slideX(begin: 0.2, end: 0.0),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  /// Navigate to the add/edit quote page.
  void goToAddQuotePage(BuildContext context) {
    NavigationStateHelper.quote = Quote.empty();
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }
}
