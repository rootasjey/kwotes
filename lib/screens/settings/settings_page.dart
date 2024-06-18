import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/settings/account_settings.dart";
import "package:kwotes/screens/settings/settings_page_body.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/types/enums/enum_account_displayed.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";

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

  /// Page scroll controller.
  ScrollController? _pageScrollController;

  @override
  void initState() {
    super.initState();
    initProps();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dividerColor = isDark ? Colors.white12 : Colors.black12;

    final Widget scaffold = SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          controller: _pageScrollController,
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onScrollToTop: scrollToTop,
              onTapCloseIcon: onTapCloseIcon,
              title: "settings.name".tr(),
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
                  isDark: isDark,
                  dividerColor: dividerColor,
                  onTap: onTapAccount,
                  enumAccountDisplayed: _enumAccountDisplayed,
                  foregroundColor: foregroundColor,
                  isMobileSize: isMobileSize,
                  onTapUpdateEmail: onTapUpdateEmail,
                  onTapUpdatePassword: onTapUpdatePassword,
                  onTapUpdateUsername: onTapUpdateUsername,
                  onTapSignout: onConfirmSignOut,
                  onTapDeleteAccount: onTapDeleteAccount,
                  onTapAccountDisplayedValue: onTapAccountDisplayedValue,
                  userFirestore: userFirestore,
                );
              },
            ),
            const SettingsPageBody(
              margin: EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 18.0,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 200.0)),
          ],
        ),
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
    final ScrollController? bottomSheetController =
        NavigationStateHelper.bottomSheetScrollController;

    if (bottomSheetController != null) {
      _pageScrollController = bottomSheetController;
    }

    _accentColors
      ..add(Constants.colors.getRandomFromPalette(onlyDarkerColors: true))
      ..add(Constants.colors.getRandomFromPalette(onlyDarkerColors: true))
      ..add(Constants.colors.getRandomFromPalette(onlyDarkerColors: true))
      ..add(Constants.colors.getRandomFromPalette(onlyDarkerColors: true));

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

  /// Navigate to the credits page.
  void onTapCredits() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.creditsRoute,
    );
  }

  /// Navigate to the delete account page.
  void onTapDeleteAccount() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.deleteAccountRoute,
    );
  }

  /// Logout the user if confirmed.
  void onConfirmSignOut() async {
    Utils.graphic.onConfirmSignOut(
      context,
      isMobileSize: Utils.measurements.isMobileSize(context),
      onCancel: (BuildContext innerContext) {
        Navigator.of(innerContext).pop();
      },
      onConfirm: (BuildContext innerContext) async {
        Navigator.of(innerContext).pop();
        final bool success = await Utils.state.signOut();
        if (!success) return;
        if (!mounted) return;

        Beamer.of(innerContext, root: true).beamToReplacementNamed(
          HomeLocation.route,
        );
      },
    );
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

  /// Scroll to the top of the page.
  void scrollToTop() {
    _pageScrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  /// Close the settings bottom sheet.
  void onTapCloseIcon() {
    Navigator.pop(NavigationStateHelper.rootContext ?? context);
  }

  void onTapAccount() {
    Beamer.of(context).beamToNamed(
      SettingsContentLocation.accountRoute,
    );
  }
}
