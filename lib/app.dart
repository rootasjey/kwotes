import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/globals/utils/calligraphy.dart";
import "package:kwotes/router/app_routes.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";

/// Main app class.
class App extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const App({
    Key? key,
    this.savedThemeMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Solid(
      signals: {
        EnumSignalId.userAuth: () => Utils.state.userAuth,
        EnumSignalId.userFirestore: () => Utils.state.userFirestore,
      },
      child: AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
          fontFamily: Calligraphy.fontFamily,
          scaffoldBackgroundColor: Constants.colors.lightBackground,
          primaryColor: Constants.colors.primary,
          secondaryHeaderColor: Constants.colors.secondary,
          colorScheme: ColorScheme.light(
            background: Constants.colors.lightBackground,
          ),
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
          fontFamily: Calligraphy.fontFamily,
          scaffoldBackgroundColor: Constants.colors.dark,
          primaryColor: Constants.colors.primary,
          secondaryHeaderColor: Constants.colors.secondary,
          colorScheme: ColorScheme.dark(
            background: Constants.colors.dark,
          ),
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
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
            routerDelegate: appLocationBuilder,
            routeInformationParser: BeamerParser(),
          );
        },
      ),
    );
  }
}
