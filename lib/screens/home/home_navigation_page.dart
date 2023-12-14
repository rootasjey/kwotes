import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/types/intents/escape_intent.dart";

class HomeNavigationPage extends StatefulWidget {
  /// Deep navigation container for home page.
  const HomeNavigationPage({super.key});

  @override
  State<HomeNavigationPage> createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  /// Beamer key to navigate sub-locations.
  final GlobalKey<BeamerState> _beamerKey = GlobalKey<BeamerState>();

  /// Beamer delegate to navigate sub-locations.
  /// NOTE: Create delegate outside build method.
  final BeamerDelegate _routerDelegate = BeamerDelegate(
    locationBuilder: BeamerLocationBuilder(beamLocations: [
      HomeContentLocation(),
    ]),
  );

  /// Keyboard shortcuts definition.
  final Map<LogicalKeySet, Intent> _shortcuts = {
    LogicalKeySet(
      LogicalKeyboardKey.escape,
    ): const EscapeIntent(),
  };

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: {
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: onEscapeShortcut,
          ),
        },
        child: HeroControllerScope(
          controller: HeroController(),
          child: Beamer(
            key: _beamerKey,
            routerDelegate: _routerDelegate,
          ),
        ),
      ),
    );
  }

  /// Callback fired to navigate to previous location.
  Object? onEscapeShortcut(EscapeIntent intent) {
    Utils.passage.deepBack(context);
    return null;
  }
}
