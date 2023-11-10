import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/topic_card.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

class HomeTopics extends StatelessWidget {
  const HomeTopics({
    super.key,
    required this.topics,
    this.isDark = false,
    this.backgroundColor,
    this.cardBackgroundColor,
    this.onTapTopic,
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Background color.
  final Color? backgroundColor;

  /// Card's background color.
  final Color? cardBackgroundColor;

  /// Callback fired when topic is tapped.
  final void Function(Topic topic)? onTapTopic;

  /// List of topics.
  final List<Topic> topics;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(
          top: 24.0,
          bottom: 42.0,
        ),
        color: backgroundColor,
        child: Column(
          children: [
            Text(
              "topics.name".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: foregroundColor?.withOpacity(0.4),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              "topic.home_description".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.3),
                ),
              ),
            ),
            Container(
              height: 100.0,
              padding: const EdgeInsets.only(
                top: 12.0,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                scrollDirection: Axis.horizontal,
                children: topics.map((Topic topic) {
                  return TopicCard(
                    backgroundColor: cardBackgroundColor,
                    heroTag: topic.name,
                    iconSize: 18.0,
                    margin: const EdgeInsets.all(8.0),
                    onTap: onTapTopic,
                    size: const Size(70.0, 70.0),
                    startElevation: 4.0,
                    topic: topic,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
