import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";
import "package:kwotes/types/intents/add_quote_intent.dart";
import "package:kwotes/types/intents/index_intent.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";

class DashboardNavigationPage extends StatefulWidget {
  /// Deep navigation container for dashboard page.
  const DashboardNavigationPage({super.key});

  @override
  State<DashboardNavigationPage> createState() =>
      _DashboardNavigationPageState();
}

class _DashboardNavigationPageState extends State<DashboardNavigationPage> {
  /// Beamer for deep navigation.
  final Beamer _beamer = Beamer(
    key: NavigationStateHelper.dashboardBeamerKey,
    routerDelegate: NavigationStateHelper.dashboardRouterDelegate,
  );

  /// Keyboard shortcuts definition.
  final Map<SingleActivator, Intent> _shortcuts = {
    const SingleActivator(
      LogicalKeyboardKey.digit1,
      control: true,
      shift: true,
    ): const FirstIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit2,
      control: true,
      shift: true,
    ): const SecondIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit3,
      control: true,
      shift: true,
    ): const ThirdIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit4,
      control: true,
      shift: true,
    ): const FourthIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit5,
      control: true,
      shift: true,
    ): const FifthIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit6,
      control: true,
      shift: true,
    ): const SixthIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.keyN,
      meta: true,
    ): const AddQuoteIntent(),
  };

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: {
          FirstIndexIntent: CallbackAction<FirstIndexIntent>(
            onInvoke: onFirstIndexShortcut,
          ),
          SecondIndexIntent: CallbackAction<SecondIndexIntent>(
            onInvoke: onSecondIndexShortcut,
          ),
          ThirdIndexIntent: CallbackAction<ThirdIndexIntent>(
            onInvoke: onThirdIndexShortcut,
          ),
          FourthIndexIntent: CallbackAction<FourthIndexIntent>(
            onInvoke: onFourthIndexShortcut,
          ),
          FifthIndexIntent: CallbackAction<FifthIndexIntent>(
            onInvoke: onFifthIndexShortcut,
          ),
          SixthIndexIntent: CallbackAction<SixthIndexIntent>(
            onInvoke: onSixthIndexShortcut,
          ),
          AddQuoteIntent: CallbackAction<AddQuoteIntent>(
            onInvoke: onAddQuoteShortcut,
          ),
        },
        child: HeroControllerScope(
          controller: HeroController(),
          child: _beamer,
        ),
      ),
    );
  }

  /// Return `true` if user can add quote
  /// depending on user plan and free plan limit.
  /// Navigate to premium page if false.
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

  /// Callback fired to navigate to add quote location.
  Object? onAddQuoteShortcut(AddQuoteIntent intent) {
    if (!canAddQuote()) return null;
    NavigationStateHelper.quote = Quote.empty();
    NavigationStateHelper.dashboardBeamerKey.currentState?.routerDelegate
        .beamToNamed(
      DashboardContentLocation.addQuoteRoute,
    );

    return null;
  }

  /// Callback fired to navigate to favourites page.
  Object? onFirstIndexShortcut(FirstIndexIntent intent) {
    NavigationStateHelper.dashboardBeamerKey.currentState?.routerDelegate
        .beamToNamed(
      DashboardContentLocation.favouritesRoute,
    );

    return null;
  }

  /// Callback fired to navigate to lists page.
  Object? onSecondIndexShortcut(SecondIndexIntent intent) {
    NavigationStateHelper.dashboardBeamerKey.currentState?.routerDelegate
        .beamToNamed(
      DashboardContentLocation.listsRoute,
    );

    return null;
  }

  /// Callback fired to navigate to in validation page.
  Object? onThirdIndexShortcut(ThirdIndexIntent intent) {
    NavigationStateHelper.dashboardBeamerKey.currentState?.routerDelegate
        .beamToNamed(
      DashboardContentLocation.inValidationRoute,
    );

    return null;
  }

  /// Callback fired to navigate to published page.
  Object? onFourthIndexShortcut(FourthIndexIntent intent) {
    NavigationStateHelper.dashboardBeamerKey.currentState?.routerDelegate
        .beamToNamed(
      DashboardContentLocation.publishedRoute,
    );

    return null;
  }

  /// Callback fired to navigate to drafts page.
  Object? onFifthIndexShortcut(FifthIndexIntent intent) {
    NavigationStateHelper.dashboardBeamerKey.currentState?.routerDelegate
        .beamToNamed(
      DashboardContentLocation.draftsRoute,
    );

    return null;
  }

  /// Callback fired to navigate to settings page.
  Object? onSixthIndexShortcut(SixthIndexIntent intent) {
    NavigationStateHelper.dashboardBeamerKey.currentState?.routerDelegate
        .beamToNamed(
      DashboardContentLocation.settingsRoute,
    );

    return null;
  }
}
