import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/topic_card.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

class ShowcaseQuotes extends StatelessWidget {
  const ShowcaseQuotes({
    super.key,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.topicColors = const [],
    this.onTapTopicColor,
  });

  /// Adapt UI to mobile size.
  final bool isMobileSize;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when a topic color is tapped.
  final void Function(Topic topicColor)? onTapTopicColor;

  /// List of topic colors.
  final List<Topic> topicColors;

  @override
  Widget build(BuildContext context) {
    const double spacing = 12.0;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Brightness brightness = Theme.of(context).brightness;
    final Color? backgroundColor =
        brightness == Brightness.light ? Colors.white38 : null;

    return SliverPadding(
      padding: margin,
      sliver: SliverList.list(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "topics.name".tr(),
            textAlign: TextAlign.center,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: foregroundColor?.withOpacity(0.4),
              ),
            ),
          ),
        ),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: topicColors
              .map(
                (Topic topicColor) {
                  return TopicCard(
                    topic: topicColor,
                    backgroundColor: backgroundColor,
                    onTap: onTapTopicColor,
                    size: isMobileSize
                        ? const Size(90.0, 90.0)
                        : const Size(100.0, 100.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  );
                },
              )
              .toList()
              .animate(interval: 15.ms)
              .fadeIn(duration: 125.ms, curve: Curves.decelerate)
              .slideY(begin: 0.2, end: 0.0),
        ),
      ]),
    );
  }
}
