import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/search_location.dart";
import "package:kwotes/screens/dashboard/dahboard_side_menu.dart";
import "package:kwotes/types/intents/add_quote_intent.dart";
import "package:kwotes/types/intents/dashboard_intent.dart";
import "package:kwotes/types/intents/escape_intent.dart";
import "package:kwotes/types/intents/home_intent.dart";
import "package:kwotes/types/intents/index_intent.dart";
import "package:kwotes/types/intents/search_intent.dart";

class DashboardPage extends StatefulWidget {
  /// Dashboard page.
  /// Personal user space.
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// Beamer key to navigate sub-locations.
  final GlobalKey<BeamerState> _beamerKey = GlobalKey<BeamerState>();

  /// Beamer delegate to navigate sub-locations.
  /// NOTE: Create delegate outside build method.
  final BeamerDelegate _routerDelegate = BeamerDelegate(
    locationBuilder: BeamerLocationBuilder(beamLocations: [
      DashboardContentLocation(),
    ]),
  );

  /// Keyboard shortcuts definition.
  final Map<LogicalKeySet, Intent> _shortcuts = {
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.digit1,
    ): const FirstIndexIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.digit2,
    ): const SecondIndexIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.digit3,
    ): const ThirdIndexIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.digit4,
    ): const FourthIndexIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.digit5,
    ): const FifthIndexIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.digit6,
    ): const SixthIndexIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyD,
    ): const DashboardIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyH,
    ): const HomeIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyS,
    ): const SearchIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.escape,
    ): const EscapeIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyN,
    ): const AddQuoteIntent(),
  };

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

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
          DashboardIntent: CallbackAction<DashboardIntent>(
            onInvoke: onDashboardShortcut,
          ),
          SearchIntent: CallbackAction<SearchIntent>(
            onInvoke: onSearchShortcut,
          ),
          HomeIntent: CallbackAction<HomeIntent>(
            onInvoke: onHomeShortcut,
          ),
          AddQuoteIntent: CallbackAction<AddQuoteIntent>(
            onInvoke: onAddQuoteShortcut,
          ),
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: onEscapeShortcut,
          ),
        },
        child: HeroControllerScope(
          controller: HeroController(),
          child: Stack(
            children: [
              Beamer(
                key: _beamerKey,
                routerDelegate: _routerDelegate,
              ),
              if (!isMobileSize)
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: DashboardSideMenu(
                    beamerKey: _beamerKey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Callback fired to navigate to favourites page.
  Object? onFirstIndexShortcut(FirstIndexIntent intent) {
    _beamerKey.currentState?.routerDelegate.beamToNamed(
      DashboardContentLocation.favouritesRoute,
    );

    return null;
  }

  /// Callback fired to navigate to lists page.
  Object? onSecondIndexShortcut(SecondIndexIntent intent) {
    _beamerKey.currentState?.routerDelegate.beamToNamed(
      DashboardContentLocation.listsRoute,
    );

    return null;
  }

  /// Callback fired to navigate to in validation page.
  Object? onThirdIndexShortcut(ThirdIndexIntent intent) {
    _beamerKey.currentState?.routerDelegate.beamToNamed(
      DashboardContentLocation.inValidationRoute,
    );

    return null;
  }

  /// Callback fired to navigate to published page.
  Object? onFourthIndexShortcut(FourthIndexIntent intent) {
    _beamerKey.currentState?.routerDelegate.beamToNamed(
      DashboardContentLocation.publishedRoute,
    );

    return null;
  }

  /// Callback fired to navigate to drafts page.
  Object? onFifthIndexShortcut(FifthIndexIntent intent) {
    _beamerKey.currentState?.routerDelegate.beamToNamed(
      DashboardContentLocation.draftsRoute,
    );

    return null;
  }

  /// Callback fired to navigate to settings page.
  Object? onSixthIndexShortcut(SixthIndexIntent intent) {
    _beamerKey.currentState?.routerDelegate.beamToNamed(
      DashboardContentLocation.settingsRoute,
    );

    return null;
  }

  /// Callback fired to navigate to dashboard page.
  Object? onDashboardShortcut(DashboardIntent intent) {
    _beamerKey.currentState?.routerDelegate.beamToNamed(
      DashboardLocation.route,
    );

    return null;
  }

  /// Callback fired to navigate to home page.
  Object? onHomeShortcut(HomeIntent intent) {
    _beamerKey.currentState?.routerDelegate.root.beamToNamed(
      HomeLocation.route,
    );

    return null;
  }

  /// Callback fired to navigate to search page.
  Object? onSearchShortcut(SearchIntent intent) {
    _beamerKey.currentState?.routerDelegate.root.beamToNamed(
      SearchLocation.route,
    );

    return null;
  }

  /// Callback fired to navigate to previous location.
  Object? onEscapeShortcut(EscapeIntent intent) {
    final BeamerDelegate? beamerDelegate =
        _beamerKey.currentState?.routerDelegate;

    if (beamerDelegate?.canBeamBack ?? false) {
      beamerDelegate?.beamBack();
      return null;
    }

    Beamer.of(context).beamBack();
    return null;
  }

  /// Callback fired to navigate to add quote location.
  Object? onAddQuoteShortcut(AddQuoteIntent intent) {
    _beamerKey.currentState?.routerDelegate.beamToNamed(
      DashboardContentLocation.addQuoteRoute,
    );

    return null;
  }
}
