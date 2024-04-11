import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";

class UserInterfacePage extends StatefulWidget {
  const UserInterfacePage({super.key});

  @override
  State<UserInterfacePage> createState() => _UserInterfacePageState();
}

class _UserInterfacePageState extends State<UserInterfacePage> {
  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SettingsPageHeader(
            isMobileSize: isMobileSize,
            onTapBackButton: context.beamBack,
            title: "settings.ui".tr(),
            // title: "user_interface.name".tr(),
          ),
          SliverPadding(
            padding: isMobileSize
                ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
                : const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                SwitchListTile(
                  activeColor: Constants.colors.authors,
                  value: NavigationStateHelper.fullscreenQuotePage,
                  onChanged: onToggleFullscreen,
                  title: Text(
                    "settings.fullscreen_quote_page.name".tr(),
                  ),
                  subtitle: Text(
                    "settings.fullscreen_quote_page.description".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 14.0,
                        color: foregroundColor?.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                SwitchListTile(
                  activeColor: Constants.colors.authors,
                  value: NavigationStateHelper.minimalQuoteActions,
                  onChanged: onToggleMinimalQuoteActions,
                  title: Text(
                    "settings.minimal_quote_actions.name".tr(),
                  ),
                  subtitle: Text(
                    "settings.minimal_quote_actions.description".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 14.0,
                        color: foregroundColor?.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text("settings.frame_border_style.name".tr()),
                  subtitle: Text(
                    "settings.frame_border_style.description".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 14.0,
                        color: foregroundColor?.withOpacity(0.4),
                      ),
                    ),
                  ),
                  trailing: const Icon(TablerIcons.chevron_right),
                  onTap: onTapFrameBorderStyle,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void onToggleFullscreen(bool value) {
    final bool newValue = !NavigationStateHelper.fullscreenQuotePage;
    Utils.vault.setFullscreenQuotePage(newValue);

    setState(() {
      NavigationStateHelper.fullscreenQuotePage = newValue;
    });
  }

  void onToggleMinimalQuoteActions(bool value) {
    final bool newValue = !NavigationStateHelper.minimalQuoteActions;
    Utils.vault.setMinimalQuoteActions(newValue);

    setState(() {
      NavigationStateHelper.minimalQuoteActions = newValue;
    });
  }

  void onTapFrameBorderStyle() {
    context.beamToNamed(SettingsContentLocation.frameBorderStyleRoute);
  }
}
