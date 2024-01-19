import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:kwotes/router/navigation_state_helper.dart";

class HomeNavigationPage extends StatefulWidget {
  /// Deep navigation container for home page.
  const HomeNavigationPage({super.key});

  @override
  State<HomeNavigationPage> createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  /// Beamer for deep navigation.
  final Beamer _beamer = Beamer(
    key: NavigationStateHelper.homeBeamerKey,
    routerDelegate: NavigationStateHelper.homeRouterDelegate,
  );

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: HeroController(),
      child: _beamer,
    );
  }
}
