import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class FeedbackCompleteView extends StatelessWidget {
  const FeedbackCompleteView({
    super.key,
    this.accentColor = Colors.amber,
    this.margin = EdgeInsets.zero,
    this.onGoBack,
  });

  /// Accent color.
  final Color accentColor;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Callback fired when user taps to go back.
  final void Function()? onGoBack;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverPadding(
      padding: margin,
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(TablerIcons.square_rounded_check_filled),
            ),
            Text(
              "feedback.sent".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w400,
                  color: foregroundColor?.withOpacity(0.8),
                ),
              ),
            ),
            Text(
              "feedback.sent_description".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: foregroundColor?.withOpacity(0.4),
                ),
              ),
            ),
            Text(
              "feedback.sent_description_2".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: foregroundColor?.withOpacity(0.4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton.icon(
                onPressed: onGoBack,
                icon: const Icon(TablerIcons.arrow_back, size: 18.0),
                label: Text("back".tr()),
                style: ElevatedButton.styleFrom(
                  foregroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: accentColor,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
