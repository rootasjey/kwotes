import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/types/enums/enum_frame_border_style.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";

class FrameBorderStylePage extends StatefulWidget {
  const FrameBorderStylePage({super.key});

  @override
  State<FrameBorderStylePage> createState() => _FrameBorderStylePageState();
}

class _FrameBorderStylePageState extends State<FrameBorderStylePage> {
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
            title: "settings.frame_border_style.name".tr(),
            // title: "user_interface.name".tr(),
          ),
          SliverPadding(
            padding: isMobileSize
                ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
                : const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed(
                EnumFrameBorderStyle.values.map(
                  (EnumFrameBorderStyle frameBorderStyle) {
                    final bool selected =
                        NavigationStateHelper.frameBorderStyle ==
                            frameBorderStyle;

                    final String textValue =
                        "settings.frame_border_style.options.${frameBorderStyle.name}.name"
                            .tr();

                    final String subtitleValue =
                        "settings.frame_border_style.options.${frameBorderStyle.name}.description"
                            .tr();

                    return ListTile(
                      selected: selected,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      titleTextStyle: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 16.0,
                          color: foregroundColor?.withOpacity(0.8),
                        ),
                      ),
                      trailing: selected ? const Icon(TablerIcons.check) : null,
                      title: Text(textValue),
                      subtitle: Opacity(
                        opacity: 0.4,
                        child: Text(
                          subtitleValue,
                          style: Utils.calligraphy.body(
                            textStyle: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                      onTap: () => onApplyBorderStyle(frameBorderStyle),
                    );
                  },
                ).toList(),
              ),
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

  void onApplyBorderStyle(EnumFrameBorderStyle frameBorderStyle) {
    Utils.vault.setFrameBorderStyle(frameBorderStyle);
    setState(() {
      NavigationStateHelper.frameBorderStyle = frameBorderStyle;
    });

    final Color borderColor = Constants.colors.getBorderColorFromStyle(
      context,
      frameBorderStyle,
    );

    final Signal<Color> frameColorSignal = context.get<Signal<Color>>(
      EnumSignalId.frameBorderColor,
    );

    frameColorSignal.update((Color previousColor) => borderColor);
  }
}
