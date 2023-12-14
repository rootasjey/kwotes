import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:infinite_carousel/infinite_carousel.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/components/topic_card.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

class TopicCarousel extends StatelessWidget {
  /// A topic carousel.
  /// Suitable for desktop or large screens.
  ///
  /// See also:
  ///   * [HomeTopics]
  const TopicCarousel({
    super.key,
    required this.topics,
    required this.scrollController,
    this.enableLeftArrow = false,
    this.enableRightArrow = true,
    this.isDark = false,
    this.foregroundColor,
    this.margin = EdgeInsets.zero,
    this.onIndexChanged,
    this.onTapTopic,
    this.onHoverTopic,
    this.onTapArrowLeft,
    this.onTapArrowRight,
    this.hoveredTopicName = "",
    this.itemExtent = 100.0,
  });

  /// Display right arrow if true.
  final bool enableLeftArrow;

  /// Display right arrow if true.
  final bool enableRightArrow;

  /// Whether to use dark theme.
  final bool isDark;

  /// Foreground text color.
  final Color? foregroundColor;

  /// Maximum width for single item in viewport.
  final double itemExtent;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when topic is tapped.
  final void Function(Topic topic)? onTapTopic;

  /// Callback fired when topic is hovered.
  final void Function(Topic topic, bool isHovered)? onHoverTopic;

  /// Callback fired when index is changed.
  final void Function(int index)? onIndexChanged;

  /// Callback fired when left arrow is tapped.
  final void Function()? onTapArrowLeft;

  /// Callback fired when right arrow is tapped.
  final void Function()? onTapArrowRight;

  /// List of topics (main data).
  final List<Topic> topics;

  /// Current scroll controller.
  final ScrollController scrollController;

  /// Current hovered topic's name.
  final String hoveredTopicName;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Divider(
            thickness: isDark ? 1.0 : 2.0,
            color: isDark ? foregroundColor?.withOpacity(0.4) : null,
          ),
          Container(
            padding: margin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 0.0),
                  child: Text(
                    hoveredTopicName.isEmpty
                        ? "topics.single".tr()
                        : "topic.$hoveredTopicName".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        color: foregroundColor?.withOpacity(0.7),
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100.0,
                  child: InfiniteCarousel.builder(
                    center: false,
                    loop: false,
                    itemCount: topics.length,
                    itemExtent: itemExtent,
                    controller: scrollController,
                    onIndexChanged: onIndexChanged,
                    scrollBehavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.stylus,
                        PointerDeviceKind.trackpad,
                        PointerDeviceKind.invertedStylus,
                      },
                    ),
                    itemBuilder:
                        (BuildContext context, int index, int realIndex) {
                      final Topic topic = topics[index];
                      return TopicCard(
                        showName: false,
                        backgroundColor: topic.color.withOpacity(0.2),
                        heroTag: topic.name,
                        iconSize: 18.0,
                        margin: const EdgeInsets.all(12.0),
                        onTap: onTapTopic,
                        onHover: onHoverTopic,
                        size: const Size(76.0, 70.0),
                        startElevation: 0.0,
                        topic: topic,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: isDark
                              ? BorderSide(color: topic.color, width: 1.0)
                              : BorderSide.none,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "topics.open_card".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      CircleButton(
                        backgroundColor: Colors.transparent,
                        onTap: enableLeftArrow ? onTapArrowLeft : null,
                        icon: Icon(
                          TablerIcons.arrow_left,
                          color: enableLeftArrow
                              ? foregroundColor?.withOpacity(0.8)
                              : foregroundColor?.withOpacity(0.2),
                        ),
                      ),
                      Container(
                        height: 6.0,
                        width: 6.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Constants.colors.secondary,
                        ),
                      ),
                      CircleButton(
                        backgroundColor: Colors.transparent,
                        onTap: enableRightArrow ? onTapArrowRight : null,
                        icon: Icon(
                          TablerIcons.arrow_right,
                          color: enableRightArrow
                              ? foregroundColor?.withOpacity(0.8)
                              : foregroundColor?.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: isDark ? 1.0 : 2.0,
            color: isDark ? foregroundColor?.withOpacity(0.4) : null,
          ),
        ],
      ),
    );
  }
}
