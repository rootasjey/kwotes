import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/screens/color_palette/color_palette_page_body.dart";
import "package:kwotes/types/enums/enum_color_value_type.dart";
import "package:kwotes/types/topic.dart";

class ColorPalettePage extends StatelessWidget {
  /// A page showing the color palette.
  const ColorPalettePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    final bool isMobileSize =
        windowSize.width <= Utils.measurements.mobileWidthTreshold;

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(slivers: [
          ColorPalettePageBody(
            isMobileSize: isMobileSize,
            onCopyHex: (Topic topic) => onCopyHex(context, topic),
            onCopyRGBA: (Topic topic) => onCopyRGBA(context, topic),
            onCopyValue: (Topic topic) => onCopyValue(context, topic),
            onTapColorCard: (Topic topic) => onTapColorCard(context, topic),
            onLongPressColorCard: (Topic topic) => onCopyValue(
              context,
              topic,
            ),
            windowSize: windowSize,
          ),
        ]),
      ),
    );
  }

  /// Callback fired when color card is tapped.
  /// Navigates to the color detail page.
  void onTapColorCard(BuildContext context, Topic topic) {
    context.beamToNamed(
      DashboardContentLocation.colorDetailRoute.replaceFirst(
        ":topicName",
        topic.name,
      ),
    );
  }

  /// Callback fired to copy color's 32-bit value.
  void onCopyValue(BuildContext context, Topic topic) {
    Clipboard.setData(ClipboardData(text: topic.color.value.toString()));

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyColorSnackbar(
      context,
      isMobileSize: isMobileSize,
      topic: topic,
      valueType: EnumColorValueType.value,
    );
  }

  /// Callback fired to copy color's RGBA value.
  void onCopyRGBA(BuildContext context, Topic topic) {
    final Color color = topic.color;

    Clipboard.setData(
      ClipboardData(
        text: "(${color.red}, "
            "${color.green}, ${color.blue}, "
            "${color.alpha})",
      ),
    );

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyColorSnackbar(
      context,
      isMobileSize: isMobileSize,
      topic: topic,
      valueType: EnumColorValueType.rgba,
    );
  }

  /// Callback fired to copy color's hex value.
  void onCopyHex(BuildContext context, Topic topic) {
    final Color color = topic.color;

    Clipboard.setData(
      ClipboardData(
        text: "#${color.value.toRadixString(16).toUpperCase().substring(2)}",
      ),
    );

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyColorSnackbar(
      context,
      isMobileSize: isMobileSize,
      topic: topic,
      valueType: EnumColorValueType.hex,
    );
  }
}
