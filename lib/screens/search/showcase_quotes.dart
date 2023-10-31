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
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final double spacing = isMobileSize ? 0.0 : 12.0;

    return SliverPadding(
      // padding: margin.add(const EdgeInsets.only(left: 24.0)),
      padding: margin.add(const EdgeInsets.only(left: 0.0)),
      sliver: SliverList.list(children: [
        Text(
          "...${"search.some_topics".tr()}".toLowerCase(),
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: foregroundColor?.withOpacity(0.4),
            ),
          ),
        ),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: topicColors
              .map(
                (Topic topicColor) {
                  return TopicCard(
                    topic: topicColor,
                    foregroundColor: foregroundColor,
                    onTapTopicColor: onTapTopicColor,
                    isTiny: isMobileSize,
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
