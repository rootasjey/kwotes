import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/buttons/dot_close_button.dart";
import "package:kwotes/globals/utils.dart";

class TitleDialog extends StatelessWidget {
  /// A component displaying a title and subtitle with a close button.
  const TitleDialog({
    Key? key,
    required this.titleValue,
    required this.subtitleValue,
    required this.onCancel,
    this.accentColor = Colors.blue,
  }) : super(key: key);

  /// Accent color.
  final MaterialColor accentColor;

  /// Text title.
  final String titleValue;

  /// Text subtitle.
  final String subtitleValue;

  /// Close button callback.
  final void Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Stack(
      children: [
        Positioned(
          top: 12.0,
          left: 12.0,
          child: DotCloseButton(
            tooltip: "cancel".tr(),
            onTap: onCancel,
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Column(
                children: [
                  if (titleValue.isNotEmpty)
                    Text(
                      titleValue,
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          color: foregroundColor?.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (subtitleValue.isNotEmpty)
                    Text(
                      subtitleValue,
                      textAlign: TextAlign.center,
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 18.0,
                          color: foregroundColor?.withOpacity(0.4),
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Divider(
                thickness: 2.0,
                color: accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
