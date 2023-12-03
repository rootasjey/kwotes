import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/globals/utils/calligraphy.dart";
import "package:kwotes/router/app_routes.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";

/// Main app class.
class App extends StatefulWidget {
  const App({
    Key? key,
    this.savedThemeMode,
  }) : super(key: key);

  /// Saved theme mode (e.g. dark, lightn system).
  final AdaptiveThemeMode? savedThemeMode;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  EnumPageState _pageState = EnumPageState.loading;

  @override
  void initState() {
    super.initState();
    initProps();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      fontFamily: Calligraphy.fontFamily,
      scaffoldBackgroundColor: Constants.colors.lightBackground,
      primaryColor: Constants.colors.primary,
      secondaryHeaderColor: Constants.colors.secondary,
      colorScheme: ColorScheme.light(
        background: Constants.colors.lightBackground,
      ),
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      fontFamily: Calligraphy.fontFamily,
      scaffoldBackgroundColor: Constants.colors.dark,
      primaryColor: Constants.colors.primary,
      secondaryHeaderColor: Constants.colors.secondary,
      cardColor: Colors.black26,
      colorScheme: ColorScheme.dark(
        background: Constants.colors.dark,
      ),
    );

    if (_pageState == EnumPageState.loading) {
      return MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        home: LoadingView.scaffold(),
      );
    }

    return Solid(
      signals: {
        EnumSignalId.userAuth: () => Utils.state.userAuth,
        EnumSignalId.userFirestore: () => Utils.state.userFirestore,
        EnumSignalId.navigationBar: () => Utils.state.showNavigationBar,
        EnumSignalId.appFrameColor: () => Utils.state.appFrameColor,
      },
      child: AdaptiveTheme(
        light: lightTheme,
        dark: darkTheme,
        initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (ThemeData theme, ThemeData darkTheme) {
          return MaterialApp.router(
            title: Constants.appName,
            theme: theme,
            darkTheme: darkTheme,
            debugShowCheckedModeBanner: false,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: [
              ...context.localizationDelegates,
            ],
            routerDelegate: appBeamerDelegate,
            routeInformationParser: BeamerParser(),
            backButtonDispatcher: BeamerBackButtonDispatcher(
              delegate: appBeamerDelegate,
            ),
          );
        },
      ),
    );
  }

  void initProps() async {
    await Future.wait([
      Utils.fetchTopicsColors(),
      Utils.state.signIn(),
    ]);

    Constants.colors.fillForegroundPalette();
    Constants.colors.foregroundPalette.shuffle();

    setState(() => _pageState = EnumPageState.idle);
  }
}
