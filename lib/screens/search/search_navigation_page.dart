import "package:beamer/beamer.dart";
import "package:flutter/cupertino.dart";
import "package:kwotes/router/navigation_state_helper.dart";

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

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: HeroController(),
      child: _beamer,
    );
  }
}
