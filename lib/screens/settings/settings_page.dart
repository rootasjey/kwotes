import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/settings/about.dart";
import "package:kwotes/screens/settings/account_settings.dart";
import "package:kwotes/screens/settings/app_language_selection.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/screens/settings/theme_switcher.dart";
import "package:kwotes/types/enums/enum_accunt_displayed.dart";

/// Settings page.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
    final String? currentLanguageCode =
        EasyLocalization.of(context)?.currentLocale?.languageCode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const ApplicationBar(),
          const SettingsPageHeader(),
          const ThemeSwitcher(),
          AccountSettings(
            enumAccountDisplayed: _enumAccountDisplayed,
            onTapUpdateEmail: onTapUpdateEmail,
            onTapUpdatePassword: onTapUpdatePassword,
            onTapUpdateUsername: onTapUpdateUsername,
            onTapLogout: onTapLogout,
            onTapDeleteAccount: onTapDeleteAccount,
            onTapAccountDisplayedValue: onTapAccountDisplayedValue,
          ),
          AppLanguageSelection(
            currentLanguageCode: currentLanguageCode,
            onSelectLanguage: onSelectLanguage,
          ),
          About(
            onTapColorPalette: onTapColorPalette,
          ),
        ],
      ),
    );
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
    if (!mounted || !success) {
      return;
    }

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

  void onSelectLanguage(String locale) {
    Utils.vault.setLanguage(locale);
    EasyLocalization.of(context)?.setLocale(Locale(locale));
  }
}
