import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/dashboard/dashboard_card_section.dart";
import "package:kwotes/screens/dashboard/dashboard_header.dart";
import "package:kwotes/screens/quote_page/share_card.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";
import "package:vibration/vibration.dart";

class DashboardWelcomePage extends StatefulWidget {
  /// Dashboard welcome page.
  const DashboardWelcomePage({super.key});

  @override
  State<DashboardWelcomePage> createState() => _DashboardWelcomePageState();
}

class _DashboardWelcomePageState extends State<DashboardWelcomePage>
    with UiLoggy {
  /// True if we already handled the quick action
  /// (e.g. pull/push to trigger).
  bool _handleQuickAction = false;

  /// Previous scroll position.
  /// Used to determine if the user is scrolling up or down.
  double _prevPixelsPosition = 0.0;

  /// Trigger offset for pull to action.
  final double _pullTriggerOffset = -100.0;

  /// Trigger offset for push to action.
  final double _pushTriggerOffset = 100.0;

  /// Page scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  @override
  initState() {
    super.initState();
    initProps();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color accentColor = Constants.colors.getRandomFromPalette();

    final UserFirestore userFirestore =
        context.observe<UserFirestore>(EnumSignalId.userFirestore);

    return SafeArea(
      child: Scaffold(
        body: ImprovedScrolling(
          enableMMBScrolling: true,
          onScroll: onScroll,
          scrollController: _pageScrollController,
          child: ScrollConfiguration(
            behavior: const CustomScrollBehavior(),
            child: CustomScrollView(
              controller: _pageScrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    DashboardHeader(
                      foregroundColor: foregroundColor,
                      isDark: isDark,
                      isMobileSize: isMobileSize,
                      accentColor: accentColor,
                      onTapUsername: showSignoutBottomSheet,
                      onTapNewQuoteButton: onGoToAddQuotePage,
                      onTapUserAvatar: openSettingsPage,
                      userFirestore: userFirestore,
                    ),
                    DashboardCardSection(
                      isDark: isDark,
                      isMobileSize: isMobileSize,
                      isPremiumUser: userFirestore.plan == EnumUserPlan.premium,
                    ),
                  ]),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Set the target variable to the new value.
  /// Then set the value back to its original value after 1 second.
  void boomerangQuickActionValue(bool newValue) {
    _handleQuickAction = newValue;
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _handleQuickAction = !newValue,
    );
  }

  /// Initialize page properties.
  void initProps() async {
    Utils.state.refreshPremiumPlan();
  }

  bool canAddQuote() {
    final UserFirestore userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value;

    final bool hasReachFreeLimit = userFirestore.plan == EnumUserPlan.free &&
        userFirestore.metrics.quotes.created >= 5;

    if (!userFirestore.rights.canProposeQuote || hasReachFreeLimit) {
      if (Utils.graphic.isMobile()) {
        Beamer.of(context, root: true).beamToNamed(
          HomeLocation.premiumRoute,
        );
        return false;
      }

      Utils.graphic.showSnackbar(
        context,
        message: "premium.add_quote_reached_free_plan_limit".tr(),
      );
      return false;
    }

    return true;
  }

  /// Navigate to the add/edit quote page.
  void onGoToAddQuotePage(BuildContext context) {
    if (!canAddQuote()) return;
    NavigationStateHelper.quote = Quote.empty();
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }

  /// Open settings page.
  void openSettingsPage() {
    Beamer.of(context, root: true).beamToNamed(
      SettingsLocation.route,
    );
  }

  /// Callback on scroll.
  void onScroll(double offset) {
    final double pixelsPosition = _pageScrollController.position.pixels;

    if (pixelsPosition < _pageScrollController.position.minScrollExtent) {
      if (_prevPixelsPosition <= pixelsPosition) {
        return;
      }

      _prevPixelsPosition = pixelsPosition;
      if (pixelsPosition < _pullTriggerOffset && !_handleQuickAction) {
        boomerangQuickActionValue(true);
        if (Utils.graphic.isMobile()) {
          Vibration.vibrate(amplitude: 20, duration: 25);
        }

        NavigationStateHelper.quote = Quote.empty();
        context.beamToNamed(DashboardContentLocation.addQuoteRoute);
      }
      return;
    }

    if (pixelsPosition > _pageScrollController.position.maxScrollExtent) {
      if (_prevPixelsPosition >= pixelsPosition) {
        return;
      }

      _prevPixelsPosition = pixelsPosition;
      if (pixelsPosition > _pushTriggerOffset && !_handleQuickAction) {
        boomerangQuickActionValue(true);
        if (Utils.graphic.isMobile()) {
          Vibration.vibrate(amplitude: 20, duration: 25);
        }

        openSettingsPage();
      }
      return;
    }
  }

  void onSignout(BuildContext context) async {
    Navigator.of(context).pop();
    final bool success = await Utils.state.signOut();
    if (!success) return;
    if (!context.mounted) return;

    Beamer.of(context, root: true).beamToReplacementNamed(HomeLocation.route);
  }

  /// Show the sign out bottom sheet.
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
}
