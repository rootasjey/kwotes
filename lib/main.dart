import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:figstyle/router/admin_auth_guard.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/router/auth_guard.dart';
import 'package:figstyle/router/no_auth_guard.dart';
import 'package:figstyle/types/topic_color.dart';
import 'package:figstyle/utils/push_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:supercharged/supercharged.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await appStorage.initialize();
  PushNotifications.init();
  await Future.wait([_autoLogin(), _initColors(), _initLang()]);

  return runApp(App());
}

/// Main app class.
class App extends StatefulWidget {
  AppState createState() => AppState();
}

/// Main app class state.
class AppState extends State<App> {
  final appRouter = AppRouter(
    adminAuthGuard: AdminAuthGuard(),
    authGuard: AuthGuard(),
    noAuthGuard: NoAuthGuard(),
  );

  @override
  Widget build(BuildContext context) {
    final brightness = getBrightness();
    stateColors.refreshTheme(brightness);
    stateUser.setFirstLaunch(appStorage.isFirstLanch());

    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        fontFamily: GoogleFonts.raleway().fontFamily,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.raleway().fontFamily,
      ),
      initial: brightness == Brightness.light
          ? AdaptiveThemeMode.light
          : AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) {
        stateColors.themeData = theme;

        return MaterialApp.router(
          title: 'fig.style',
          darkTheme: darkTheme,
          theme: stateColors.themeData,
          debugShowCheckedModeBanner: false,
          routerDelegate: appRouter.delegate(),
          routeInformationParser: appRouter.defaultRouteParser(),
        );
      },
    );
  }

  Brightness getBrightness() {
    final autoBrightness = appStorage.getAutoBrightness();

    if (!autoBrightness) {
      return appStorage.getBrightness();
    }

    Brightness brightness = Brightness.light;
    final now = DateTime.now();

    if (now.hour < 6 || now.hour > 17) {
      brightness = Brightness.dark;
    }

    return brightness;
  }
}

// Initialization functions.
// ------------------------
Future _autoLogin() async {
  try {
    final userCred = await stateUser.signin();

    if (userCred == null) {
      stateUser.signOut();
    }
  } catch (error) {
    debugPrint(error.toString());
    stateUser.signOut();
  }
}

Future _initColors() async {
  await appTopicsColors.fetchTopicsColors();

  final color = appTopicsColors.shuffle(max: 1).firstOrElse(
        () => TopicColor(
          name: 'blue',
          decimal: Colors.blue.value,
          hex: Colors.blue.value.toRadixString(16),
        ),
      );

  stateColors.setAccentColor(Color(color.decimal));
}

Future _initLang() async {
  final savedLang = appStorage.getLang();
  stateUser.setLang(savedLang);
}
