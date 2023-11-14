import "dart:ui";

import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/color_palette/color_detail_page_body.dart";
import "package:kwotes/types/enums/enum_color_value_type.dart";
import "package:kwotes/types/topic.dart";

class ColorDetailPage extends StatelessWidget {
  const ColorDetailPage({
    super.key,
    required this.topicName,
  });

  /// Name of the topic to show details.
  final String topicName;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12.0);
    final Brightness? brightness = AdaptiveTheme.of(context).brightness;
    final Color backgroundColor =
        brightness == Brightness.light ? Colors.white70 : Colors.black26;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: context.beamBack,
        child: Container(
          color: Colors.black12,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(42.0),
                  child: Material(
                    elevation: 8.0,
                    color: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: borderRadius,
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: ColorDetailPageBody(
                          topicName: topicName,
                          onCopy32bitValue: onCopy32bitValue,
                          onCopyRGBA: onCopyRGBA,
                          onCopyHex: onCopyHex,
                          onTapCloseButton: context.beamBack,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onCopy32bitValue(BuildContext context, Color color) {
    Clipboard.setData(ClipboardData(text: "${color.value}"));

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyColorSnackbar(
      context,
      isMobileSize: isMobileSize,
      topic: Topic(color: color, name: topicName),
      valueType: EnumColorValueType.value,
    );
  }

  void onCopyRGBA(BuildContext context, Color color) {
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
      topic: Topic(color: color, name: topicName),
      valueType: EnumColorValueType.rgba,
    );
  }

  void onCopyHex(BuildContext context, Color color) {
    Clipboard.setData(
      ClipboardData(
        text: "#${color.value.toRadixString(16).toUpperCase().substring(2)}",
      ),
    );

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyColorSnackbar(
      context,
      isMobileSize: isMobileSize,
      topic: Topic(color: color, name: topicName),
      valueType: EnumColorValueType.hex,
    );
  }
}
