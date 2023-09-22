import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/buttons/dot_close_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

class ColorDetailPageBody extends StatelessWidget {
  const ColorDetailPageBody({
    super.key,
    required this.topicName,
    this.onCopy32bitValue,
    this.onCopyRGBA,
    this.onCopyHex,
    this.onTapCloseButton,
  });

  /// Name of the topic to show details.
  final String topicName;

  /// Callback fired to copy 32-bit color value.
  final void Function(BuildContext context, Color tColor)? onCopy32bitValue;

  /// Callback fired to copy RGBA color value.
  final void Function(BuildContext context, Color tColor)? onCopyRGBA;

  /// Callback fired to copy hexadecimal color value.
  final void Function(BuildContext context, Color tColor)? onCopyHex;

  /// Callback fired to close the page.
  final void Function()? onTapCloseButton;

  @override
  Widget build(BuildContext context) {
    final Topic topic = Constants.colors.topics.firstWhere(
      (Topic topic) => topic.name == topicName,
    );

    final tColor = topic.color;

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: topic.name,
                    child: Container(
                      width: 170.0,
                      height: 200.0,
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        color: topic.color,
                        elevation: 4.0,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: DotCloseButton(
                      onTap: onTapCloseButton,
                      tooltip: "close".tr(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                child: Text(
                  topic.name,
                  style: Utils.calligraphy.body2(
                    textStyle: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.w400,
                      color: foregroundColor?.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => onCopy32bitValue?.call(
                      context,
                      tColor,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: "32-bit value: ",
                        children: [
                          TextSpan(
                            text: "${tColor.value}",
                            style: TextStyle(
                              color: foregroundColor,
                            ),
                          ),
                        ],
                      ),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: foregroundColor?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => onCopyRGBA?.call(
                      context,
                      tColor,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: "RGBA: ",
                        children: [
                          TextSpan(
                            text: "(${tColor.red}, "
                                "${tColor.green}, ${tColor.blue}, "
                                "${tColor.alpha})",
                            style: TextStyle(
                              color: foregroundColor,
                            ),
                          ),
                        ],
                      ),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: foregroundColor?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => onCopyHex?.call(
                      context,
                      tColor,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: "HEX: ",
                        children: [
                          TextSpan(
                            text:
                                "#${tColor.value.toRadixString(16).toUpperCase()}",
                            style: TextStyle(
                              color: foregroundColor,
                            ),
                          ),
                        ],
                      ),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: foregroundColor?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
