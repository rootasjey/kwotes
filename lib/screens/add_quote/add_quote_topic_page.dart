import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/components/topic_chip.dart";
import "package:kwotes/types/topic.dart";

class AddQuoteTopicPage extends StatelessWidget {
  const AddQuoteTopicPage({
    super.key,
    required this.topics,
    this.onClearTopic,
    this.onSelected,
    this.onDeleteQuote,
    this.appBarRightChildren = const [],
  });

  /// Callback fired when a topic is tapped.
  final void Function(Topic topic, bool selected)? onSelected;

  /// Callback fired when "Clear topics" button is tapped.
  final void Function()? onClearTopic;

  /// Callback fired to delete the quote we're editing.
  final void Function()? onDeleteQuote;

  /// List of topics.
  final List<Topic> topics;

  /// Right children of the application bar.
  final List<Widget> appBarRightChildren;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        ApplicationBar(rightChildren: appBarRightChildren),
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 48.0,
            right: 54.0,
            top: 24.0,
            bottom: 240.0,
          ),
          sliver: SliverList.list(children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  "caracterization".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: const TextStyle(
                      fontSize: 42.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  "quote.add_topics".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: const TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: topics.map((topic) {
                final bool selected = NavigationStateHelper.quote.topics
                    .any((x) => x == topic.name);

                return TopicChip(
                  topic: topic,
                  selected: selected,
                  onSelected: onSelected,
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: onClearTopic,
                  child: Text(
                    "quote.clear_topics".tr(),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
