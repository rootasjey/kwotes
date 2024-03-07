import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/dashboard/dashboard_card_section.dart";
import "package:kwotes/screens/dashboard/dashboard_fab.dart";
import "package:kwotes/screens/dashboard/dashboard_header.dart";
import "package:kwotes/screens/dashboard/dashboard_last_draft.dart";
import "package:kwotes/screens/dashboard/dashboard_last_published.dart";
import "package:kwotes/screens/quote_page/share_card.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";

class DashboardWelcomePage extends StatelessWidget {
  /// Dashboard welcome page.
  const DashboardWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color randomColor = Constants.colors.getRandomFromPalette();

    final UserFirestore userFirestore =
        context.observe<UserFirestore>(EnumSignalId.userFirestore);

    return SafeArea(
      child: Scaffold(
        floatingActionButton: DashboardFab(
          isMobileSize: isMobileSize,
          onGoToAddQuotePage: onGoToAddQuotePage,
          backgroundColor: isDark ? Colors.black : Colors.white,
          splashColor: randomColor,
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                Align(
                  alignment: Alignment.topLeft,
                  child: AppIcon(
                    margin: isMobileSize
                        ? const EdgeInsets.only(top: 24.0, left: 12.0)
                        : const EdgeInsets.only(top: 24.0, left: 36.0),
                  ),
                ),
                DashboardHeader(
                  foregroundColor: foregroundColor,
                  isDark: isDark,
                  isMobileSize: isMobileSize,
                  randomColor: randomColor,
                  onTapUsername: showSignoutBottomSheet,
                  userFirestore: userFirestore,
                ),
                DashboardCardSection(
                  isDark: isDark,
                  isMobileSize: isMobileSize,
                ),
                DashboardLastDraft(
                  userFirestore: userFirestore,
                ),
                DashboardLastPublished(
                  userFirestore: userFirestore,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: ColoredTextButton(
                    textValue: "signout".tr(),
                    textFlex: 0,
                    onPressed: () => onSignout(context),
                    accentColor: randomColor,
                    backgroundColor: randomColor.withOpacity(0.2),
                    margin: isMobileSize
                        ? const EdgeInsets.only(top: 24.0, left: 24.0)
                        : const EdgeInsets.only(top: 24.0, left: 42.0),
                  ),
                ),
              ]),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)),
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

  void showSignoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "account.name".tr().toUpperCase(),
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShareCard(
                      labelValue: "signout".tr(),
                      icon: const Icon(TablerIcons.logout),
                      margin: EdgeInsets.zero,
                      onTap: () async {
                        onSignout(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onSignout(BuildContext context) async {
    Navigator.of(context).pop();
    final bool success = await Utils.state.signOut();
    if (!success) return;
    if (!context.mounted) return;

    Beamer.of(context, root: true).beamToReplacementNamed(HomeLocation.route);
  }
}
