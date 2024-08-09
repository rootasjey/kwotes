import "dart:io";

import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:firebase_app_check/firebase_app_check.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_langdetect/flutter_langdetect.dart" as langdetect;
import "package:kwotes/router/app_routes.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:loggy/loggy.dart";
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

  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    // webProvider: ReCaptchaV3Provider("recaptcha-v3-site-key"),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    // androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
  );

  Beamer.setPathUrlStrategy();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: "var.env");

  final String browserUrl = Uri.base.query.isEmpty
      ? Uri.base.path
      : "${Uri.base.path}?${Uri.base.query}";

  NavigationStateHelper.initialBrowserUrl = browserUrl;

  // Make sure that the initial route is kept correctly.
  if (kIsWeb) {
    appBeamerDelegate.setInitialRoutePath(RouteInformation(
      uri: Uri.parse(browserUrl),
    ));
  }

  final AdaptiveThemeMode? savedThemeMode = await AdaptiveTheme.getThemeMode();
  final int lastSavedTabIndex = await Utils.vault.getHomePageTabIndex();

  NavigationStateHelper.initInitialTabIndex(
    initialUrl: browserUrl,
    lastSavedIndex: lastSavedTabIndex,
  );

  NavigationStateHelper.fullscreenQuotePage =
      await Utils.vault.getFullscreenQuotePage();

  NavigationStateHelper.minimalQuoteActions =
      await Utils.vault.getMinimalQuoteActions();

  NavigationStateHelper.frameBorderStyle =
      await Utils.vault.getFrameBorderColored();

  NavigationStateHelper.showHeaderPageOptions =
      await Utils.vault.geShowtHeaderPageOptions();

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

  return runApp(
    EasyLocalization(
      path: "assets/translations",
      supportedLocales: const [Locale("en"), Locale("fr")],
      fallbackLocale: const Locale("en"),
      child: App(savedThemeMode: savedThemeMode),
    ),
  );
}
