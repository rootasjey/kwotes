import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/topic_card.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

class ShowcaseQuotes extends StatelessWidget {
  const ShowcaseQuotes({
    super.key,
    this.margin = EdgeInsets.zero,
    this.topicColors = const [],
    this.onTapTopicColor,
  });

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

    return SliverPadding(
      padding: margin.add(const EdgeInsets.only(left: 24.0)),
      sliver: SliverList.list(children: [
        Text(
          "${"search.some_topics".tr()}...",
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: foregroundColor?.withOpacity(0.4),
            ),
          ),
        ),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: topicColors
              .map(
                (Topic topicColor) {
                  return TopicCard(
                    topic: topicColor,
                    foregroundColor: foregroundColor,
                    onTapTopicColor: onTapTopicColor,
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
