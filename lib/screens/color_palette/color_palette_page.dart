import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/components/application_bar.dart";
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
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return Scaffold(
      body: CustomScrollView(slivers: [
        ApplicationBar(
          isMobileSize: isMobileSize,
        ),
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
        ),
      ]),
    );
  }

  /// Callback fired when color card is tapped.
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
    Utils.graphic.showCopyColorSnackbar(
      context,
      topic: topic,
      valueType: EnumColorValueType.value,
    );
  }

  void onCopyRGBA(BuildContext context, Topic topic) {
    final Color color = topic.color;

    Clipboard.setData(
      ClipboardData(
        text: "(${color.red}, "
            "${color.green}, ${color.blue}, "
            "${color.alpha})",
      ),
    );

    Utils.graphic.showCopyColorSnackbar(
      context,
      topic: topic,
      valueType: EnumColorValueType.rgba,
    );
  }

  void onCopyHex(BuildContext context, Topic topic) {
    final Color color = topic.color;

    Clipboard.setData(
      ClipboardData(
        text: "#${color.value.toRadixString(16).toUpperCase().substring(2)}",
      ),
    );

    Utils.graphic.showCopyColorSnackbar(
      context,
      topic: topic,
      valueType: EnumColorValueType.hex,
    );
  }
}
