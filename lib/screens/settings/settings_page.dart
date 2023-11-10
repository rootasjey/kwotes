import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/settings/about_settings.dart";
import "package:kwotes/screens/settings/account_settings.dart";
import "package:kwotes/screens/settings/app_language_selection.dart";
import "package:kwotes/screens/settings/theme_switcher.dart";
import "package:kwotes/types/enums/enum_accunt_displayed.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:url_launcher/url_launcher.dart";

/// Settings page.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.selfPageShortcutsActive = false,
  });

  /// Whether to activate the shortcut on the settings page.
  /// Set to `true` only if this page is not wrapped in a `Shortcuts`.
  final bool selfPageShortcutsActive;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// An enum representing the account displayed text value on settings page.
  EnumAccountDisplayed _enumAccountDisplayed = EnumAccountDisplayed.name;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final String? currentLanguageCode =
        EasyLocalization.of(context)?.currentLocale?.languageCode;

    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final Widget scaffold = Scaffold(
      body: CustomScrollView(
        slivers: [
          ApplicationBar(
            isMobileSize: isMobileSize,
            title: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Hero(
                tag: "settings",
                child: Text(
                  "settings.name".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // SettingsPageHeader(isMobileSize: isMobileSize),
          ThemeSwitcher(
            isMobileSize: isMobileSize,
            onTapLightTheme: onTapLightTheme,
            onTapDarkTheme: onTapDarkTheme,
            onTapSystemTheme: onTapSystemTheme,
            onToggleThemeMode: onToggleThemeMode,
          ),
          SignalBuilder(
            signal: signalUserFirestore,
            builder: (
              BuildContext context,
              UserFirestore userFirestore,
              Widget? child,
            ) {
              if (userFirestore.id.isEmpty) {
                return SliverToBoxAdapter(child: Container());
              }

              return AccountSettings(
                enumAccountDisplayed: _enumAccountDisplayed,
                isMobileSize: isMobileSize,
                onTapUpdateEmail: onTapUpdateEmail,
                onTapUpdatePassword: onTapUpdatePassword,
                onTapUpdateUsername: onTapUpdateUsername,
                onTapLogout: onTapLogout,
                onTapDeleteAccount: onTapDeleteAccount,
                onTapAccountDisplayedValue: onTapAccountDisplayedValue,
                userFirestore: userFirestore,
              );
            },
          ),
          AppLanguageSelection(
            currentLanguageCode: currentLanguageCode,
            isMobileSize: isMobileSize,
            onSelectLanguage: onSelectLanguage,
          ),
          AboutSettings(
            isMobileSize: isMobileSize,
            onTapColorPalette: onTapColorPalette,
            onTapTermsOfService: onTapTermsOfService,
            onTapGitHub: onTapGitHub,
            onTapThePurpose: onTapThePurpose,
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 200.0)),
        ],
      ),
    );

    if (!widget.selfPageShortcutsActive) {
      return scaffold;
    }

    return BasicShortcuts(
      onCancel: Beamer.of(context).beamBack,
      child: scaffold,
    );
  }

  void onSelectLanguage(EnumLanguageSelection locale) {
    Utils.vault.setLanguage(locale);
    EasyLocalization.of(context)?.setLocale(Locale(locale.name));
  }

  void onTapAccountDisplayedValue() {
    setState(() {
      _enumAccountDisplayed = _enumAccountDisplayed == EnumAccountDisplayed.name
          ? EnumAccountDisplayed.email
          : EnumAccountDisplayed.name;
    });
  }

  void onTapDeleteAccount() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.deleteAccountRoute,
    );
  }

  void onTapLogout() async {
    final bool success = await Utils.state.logout();
    if (!success) return;
    if (!mounted) return;

    Beamer.of(context, root: true).beamToReplacementNamed(HomeLocation.route);
  }

  void onTapUpdateEmail() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.updateEmailRoute,
    );
  }

  void onTapUpdatePassword() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.updatePasswordRoute,
    );
  }

  void onTapUpdateUsername() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.updateUsernameRoute,
    );
  }

  void onTapColorPalette() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.colorPaletteRoute,
    );
  }

  void onTapTermsOfService() {
    Beamer.of(context).beamToNamed(
      "terms-of-service/",
    );
  }

  void onTapGitHub() {
    launchUrl(Uri.parse(Constants.githubUrl));
  }

  void onTapThePurpose() {
    Beamer.of(context).beamToNamed(
      "the-purpose/",
    );
  }

  void onTapLightTheme() {
    AdaptiveTheme.of(context).setLight();
    Utils.vault.setBrightness(Brightness.light);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Constants.colors.lightBackground,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  void onTapDarkTheme() {
    AdaptiveTheme.of(context).setDark();
    Utils.vault.setBrightness(Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Constants.colors.dark,
        systemNavigationBarColor: Color.alphaBlend(
          Colors.black26,
          Constants.colors.dark,
        ),
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void onTapSystemTheme() {
    AdaptiveTheme.of(context).setSystem();
    updateUiBrightness();
  }

  void onToggleThemeMode() {
    AdaptiveTheme.of(context).toggleThemeMode();
    updateUiBrightness();
  }

  void updateUiBrightness() {
    final Brightness brightness =
        AdaptiveTheme.of(context).brightness ?? Brightness.light;
    Utils.vault.setBrightness(brightness);

    final bool isDark = brightness == Brightness.dark;

    final SystemUiOverlayStyle overlayStyle = isDark
        ? SystemUiOverlayStyle(
            statusBarColor: Constants.colors.dark,
            systemNavigationBarColor: Colors.black26,
            systemNavigationBarDividerColor: Colors.transparent,
          )
        : SystemUiOverlayStyle(
            statusBarColor: Constants.colors.lightBackground,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarDividerColor: Colors.transparent,
          );

    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }
}
