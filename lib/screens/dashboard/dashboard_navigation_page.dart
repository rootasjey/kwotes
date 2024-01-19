import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/types/intents/add_quote_intent.dart";
import "package:kwotes/types/intents/index_intent.dart";

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
      meta: true,
    ): const FirstIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit2,
      meta: true,
    ): const SecondIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit3,
      meta: true,
    ): const ThirdIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit4,
      meta: true,
    ): const FourthIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit5,
      meta: true,
    ): const FifthIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit6,
      meta: true,
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

  /// Callback fired to navigate to add quote location.
  Object? onAddQuoteShortcut(AddQuoteIntent intent) {
    NavigationStateHelper.dashboardBeamerKey.currentState?.routerDelegate
        .beamToNamed(
      DashboardContentLocation.addQuoteRoute,
    );

    return null;
  }
}
