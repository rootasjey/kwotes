import "dart:io";

import "package:adaptive_theme/adaptive_theme.dart";
import "package:easy_localization/easy_localization.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_langdetect/flutter_langdetect.dart" as langdetect;
import "package:kwotes/globals/utils/passage.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:loggy/loggy.dart";
import "package:url_strategy/url_strategy.dart";
import "package:window_manager/window_manager.dart";

import "package:kwotes/app.dart";
import "package:kwotes/firebase_options.dart";
import "package:kwotes/globals/utils.dart";

void main() async {
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString("google_fonts/OFL.txt");
    yield LicenseEntryWithLineBreaks(["google_fonts"], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setPathUrlStrategy();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: "var.env");

  final AdaptiveThemeMode? savedThemeMode = await AdaptiveTheme.getThemeMode();
  Passage.homePageTabIndex = await Utils.vault.getHomePageTabIndex();

  NavigationStateHelper.fullscreenQuotePage =
      await Utils.vault.getFullscreenQuotePage();

  NavigationStateHelper.minimalQuoteActions =
      await Utils.vault.getMinimalQuoteActions();

  if (!kIsWeb) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      await windowManager.ensureInitialized();

      windowManager.waitUntilReadyToShow(
        const WindowOptions(
          titleBarStyle: TitleBarStyle.hidden,
        ),
        () async => await windowManager.show(),
      );
    }
  }

  await langdetect.initLangDetect();
  await Utils.linguistic.initCurrentLanguage();

  return runApp(
    EasyLocalization(
      path: "assets/translations",
      supportedLocales: const [Locale("en"), Locale("fr")],
      fallbackLocale: const Locale("en"),
      child: App(savedThemeMode: savedThemeMode),
    ),
  );
}
