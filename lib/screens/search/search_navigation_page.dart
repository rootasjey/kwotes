import "package:beamer/beamer.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/services.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/types/intents/escape_intent.dart";

class SearchNavigationPage extends StatefulWidget {
  /// Deep navigation container for search page.
  const SearchNavigationPage({super.key});

  @override
  State<SearchNavigationPage> createState() => _SearchNavigationPageState();
}

class _SearchNavigationPageState extends State<SearchNavigationPage> {
  /// Beamer for deep navigation.
  final Beamer _beamer = Beamer(
    key: NavigationStateHelper.searchBeamerKey,
    routerDelegate: NavigationStateHelper.searchRouterDelegate,
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
          child: _beamer,
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
