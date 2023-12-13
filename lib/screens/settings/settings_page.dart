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
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/settings/about_settings.dart";
import "package:kwotes/screens/settings/account_settings.dart";
import "package:kwotes/screens/settings/app_behaviour_settings.dart";
import "package:kwotes/screens/settings/app_language_selection.dart";
import "package:kwotes/screens/settings/theme_switcher.dart";
import "package:kwotes/types/enums/enum_accunt_displayed.dart";
import "package:kwotes/types/enums/enum_app_bar_mode.dart";
import "package:kwotes/types/enums/enum_frame_border_style.dart";
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
  /// Animate elements on settings page if true.
  bool _animateElements = true;

  /// An enum representing the account displayed text value on settings page.
  EnumAccountDisplayed _enumAccountDisplayed = EnumAccountDisplayed.name;

  /// List of accent colors.
  /// For styling purpose.
  final List<Color> _accentColors = [];

  @override
  void initState() {
    super.initState();
    initProps();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final String? currentLanguageCode =
        EasyLocalization.of(context)?.currentLocale?.languageCode;

    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Widget scaffold = Scaffold(
      body: CustomScrollView(
        slivers: [
          ApplicationBar(
            isMobileSize: isMobileSize,
            mode: EnumAppBarMode.settings,
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
          ThemeSwitcher(
            accentColor: _accentColors.elementAt(0),
            animateElements: _animateElements,
            foregroundColor: foregroundColor,
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
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return AccountSettings(
                accentColor: _accentColors.elementAt(1),
                animateElements: _animateElements,
                enumAccountDisplayed: _enumAccountDisplayed,
                foregroundColor: foregroundColor,
                isMobileSize: isMobileSize,
                onTapUpdateEmail: onTapUpdateEmail,
                onTapUpdatePassword: onTapUpdatePassword,
                onTapUpdateUsername: onTapUpdateUsername,
                onTapSignout: onTapSignOut,
                onTapDeleteAccount: onTapDeleteAccount,
                onTapAccountDisplayedValue: onTapAccountDisplayedValue,
                userFirestore: userFirestore,
              );
            },
          ),
          AppLanguageSelection(
            accentColor: _accentColors.elementAt(2),
            animateElements: _animateElements,
            currentLanguageCode: currentLanguageCode,
            foregroundColor: foregroundColor,
            isMobileSize: isMobileSize,
            onSelectLanguage: onSelectLanguage,
          ),
          AppBehaviourSettings(
            accentColor: _accentColors.elementAt(3),
            animateElements: _animateElements,
            foregroundColor: foregroundColor,
            appBorderStyle: NavigationStateHelper.frameBorderStyle,
            isMobileSize: isMobileSize,
            isFullscreenQuotePage: NavigationStateHelper.fullscreenQuotePage,
            isMinimalQuoteActions: NavigationStateHelper.minimalQuoteActions,
            onToggleFrameBorderColor: onToggleFrameBorderColor,
            onToggleFullscreen: onToggleFullscreen,
            onToggleMinimalQuoteActions: onToggleMinimalQuoteActions,
          ),
          AboutSettings(
            animateElements: _animateElements,
            foregroundColor: foregroundColor,
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

  void initProps() async {
    _accentColors
      ..add(Constants.colors.getRandomFromPalette(withGoodContrast: true))
      ..add(Constants.colors.getRandomFromPalette(withGoodContrast: true))
      ..add(Constants.colors.getRandomFromPalette(withGoodContrast: true))
      ..add(Constants.colors.getRandomFromPalette(withGoodContrast: true));

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _animateElements = false);
    });
  }

  /// Apply the new selected language.
  void onSelectLanguage(EnumLanguageSelection locale) {
    Utils.vault.setLanguage(locale);
    EasyLocalization.of(context)?.setLocale(Locale(locale.name));
  }

  /// Circle between name and email to display.
  void onTapAccountDisplayedValue() {
    setState(() {
      _enumAccountDisplayed = _enumAccountDisplayed == EnumAccountDisplayed.name
          ? EnumAccountDisplayed.email
          : EnumAccountDisplayed.name;
    });
  }

  /// Navigate to the delete account page.
  void onTapDeleteAccount() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.deleteAccountRoute,
    );
  }

  /// Logout the user.
  void onTapSignOut() async {
    final bool success = await Utils.state.signOut();
    if (!success) return;
    if (!mounted) return;

    Beamer.of(context, root: true).beamToReplacementNamed(HomeLocation.route);
  }

  /// Navigate to the update email page.
  void onTapUpdateEmail() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.updateEmailRoute,
    );
  }

  /// Navigate to the update password page.
  void onTapUpdatePassword() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.updatePasswordRoute,
    );
  }

  /// Navigate to the update username page.
  void onTapUpdateUsername() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.updateUsernameRoute,
    );
  }

  /// Navigate to the color palette page.
  void onTapColorPalette() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.colorPaletteRoute,
    );
  }

  /// Navigate to the terms of service page.
  void onTapTermsOfService() {
    Beamer.of(context).beamToNamed(
      "terms-of-service/",
    );
  }

  /// Open the project's GitHub page.
  void onTapGitHub() {
    launchUrl(Uri.parse(Constants.githubUrl));
  }

  /// Navigate to the purpose page.
  void onTapThePurpose() {
    Beamer.of(context).beamToNamed(
      "the-purpose/",
    );
  }

  /// Apply light theme.
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

  /// Apply dark theme.
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

  /// Apply system theme.
  void onTapSystemTheme() {
    AdaptiveTheme.of(context).setSystem();
    updateUiBrightness();
  }

  void onToggleFrameBorderColor() {
    final int nextIndex = (NavigationStateHelper.frameBorderStyle.index + 1) %
        EnumFrameBorderStyle.values.length;

    final EnumFrameBorderStyle nextStyle =
        EnumFrameBorderStyle.values[nextIndex];

    Utils.vault.setFrameBorderStyle(nextStyle);
    setState(() {
      NavigationStateHelper.frameBorderStyle = nextStyle;
    });

    final Color borderColor = Constants.colors.getBorderColorFromStyle(
      context,
      nextStyle,
    );
    final Signal<Color> frameColorSignal = context.get<Signal<Color>>(
      EnumSignalId.frameBorderColor,
    );

    frameColorSignal.update((Color previousColor) => borderColor);
  }

  /// Turn on/off fullscreen mode on quote page.
  void onToggleFullscreen() {
    final bool newValue = !NavigationStateHelper.fullscreenQuotePage;
    Utils.vault.setFullscreenQuotePage(newValue);

    setState(() {
      NavigationStateHelper.fullscreenQuotePage = newValue;
    });
  }

  void onToggleMinimalQuoteActions() {
    final bool newValue = !NavigationStateHelper.minimalQuoteActions;
    Utils.vault.setMinimalQuoteActions(newValue);

    setState(() {
      NavigationStateHelper.minimalQuoteActions = newValue;
    });
  }

  /// Circle through light, dark and system theme.
  void onToggleThemeMode() {
    AdaptiveTheme.of(context).toggleThemeMode();
    updateUiBrightness();
  }

  /// Save the current brightness to the vault and
  /// update the system UI overlay style.
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
