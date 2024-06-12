import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/topic_card.dart";
import "package:kwotes/components/topic_tile.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/types/enums/enum_topic.dart";
import "package:kwotes/types/topic.dart";
import "package:wave_divider/wave_divider.dart";

class ShowcaseQuotes extends StatelessWidget {
  const ShowcaseQuotes({
    super.key,
    this.animateItemList = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.topicColors = const [],
    this.onTapTopic,
  });

  /// Animate item if true.
  /// Used to skip animation while scrolling.
  final bool animateItemList;

  /// Whether dark theme is active.
  final bool isDark;

  /// Adapt UI to mobile size.
  final bool isMobileSize;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when a topic color is tapped.
  final void Function(Topic topicColor)? onTapTopic;

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

    if (isMobileSize) {
      return SliverPadding(
        padding: margin,
        sliver: SliverList.separated(
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: WaveDivider(
                waveHeight: 2.0,
                waveWidth: 5.0,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.2),
              ),
            )
                .animate(
                  delay: animateItemList
                      ? Duration(milliseconds: 25 * index)
                      : null,
                )
                .fadeIn(
                  duration: animateItemList
                      ? 125.ms * index
                      : const Duration(milliseconds: 0),
                  curve: Curves.decelerate,
                )
                .slideY(
                  begin: 0.4,
                  end: 0.0,
                );
          },
          itemBuilder: (BuildContext context, int index) {
            final Topic topic = topicColors[index];
            final bool isFreeTopic = EnumFreeTopic.values
                .map((e) => e.name)
                .toList()
                .contains(topic.name);

            return TopicTile(
              topic: topic,
              isDark: isDark,
              onTap: onTapTopic,
              shape: isFreeTopic
                  ? null
                  : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Constants.colors
                            .getColorFromTopicName(
                              context,
                              topicName: topic.name,
                            )
                            .withOpacity(0.2),
                      ),
                    ),
            )
                .animate(
                  delay: animateItemList ? 25.ms * index : null,
                )
                .fadeIn(
                  duration: animateItemList
                      ? 25.ms * index
                      : const Duration(milliseconds: 0),
                  curve: Curves.decelerate,
                )
                .slideY(
                  begin: 0.4,
                  end: 0.0,
                );
          },
          itemCount: topicColors.length,
        ),
      );
    }

    return SliverPadding(
      padding: margin,
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.spaceEvenly,
          children: topicColors
              .map(
                (Topic topic) {
                  final bool isFreeTopic = EnumFreeTopic.values
                      .map((EnumFreeTopic x) => x.name)
                      .toList()
                      .contains(topic.name);

                  return TopicCard(
                    topic: topic,
                    isDark: isDark,
                    showDot: isFreeTopic ? false : true,
                    backgroundColor: backgroundColor,
                    foregroundColor: foregroundColor,
                    onTap: onTapTopic,
                    size: isMobileSize
                        ? const Size(90.0, 90.0)
                        : const Size(100.0, 100.0),
                  );
                },
              )
              .toList()
              .animate(interval: 15.ms)
              .fadeIn(duration: 125.ms, curve: Curves.decelerate)
              .slideY(begin: 0.2, end: 0.0),
        ),
      ),
    );
  }
}
