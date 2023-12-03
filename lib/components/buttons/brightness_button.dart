import "package:adaptive_theme/adaptive_theme.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";

class BrightnessButton extends StatefulWidget {
  const BrightnessButton({super.key});

  @override
  State<BrightnessButton> createState() => _BrightnessButtonState();
}

class _BrightnessButtonState extends State<BrightnessButton> {
  @override
  Widget build(BuildContext context) {
    final AdaptiveThemeMode mode = AdaptiveTheme.of(context).mode;
    return CircleButton(
      onTap: () {
        AdaptiveTheme.of(context).toggleThemeMode();
      },
      backgroundColor: getColor(mode).withOpacity(0.6),
      icon: Icon(getIcon(mode)),
      tooltip: getTooltip(mode),
    );
  }

  Color getColor(AdaptiveThemeMode mode) {
    switch (mode) {
      case AdaptiveThemeMode.light:
        return Colors.amber;
      case AdaptiveThemeMode.dark:
        return Colors.indigo;
      case AdaptiveThemeMode.system:
        return Colors.pink;
      default:
        return Colors.pink;
    }
  }

  IconData getIcon(AdaptiveThemeMode mode) {
    switch (mode) {
      case AdaptiveThemeMode.light:
        return TablerIcons.sun;
      case AdaptiveThemeMode.dark:
        return TablerIcons.moon;
      case AdaptiveThemeMode.system:
        return TablerIcons.brightness;
      default:
        return TablerIcons.sun;
    }
  }

  getTooltip(AdaptiveThemeMode mode) {
    switch (mode) {
      case AdaptiveThemeMode.light:
        return "light".tr();
      case AdaptiveThemeMode.dark:
        return "dark".tr();
      case AdaptiveThemeMode.system:
        return "system".tr();
      default:
        return "light".tr();
    }
  }
}
