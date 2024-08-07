import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/components/topic_chip.dart";
import "package:kwotes/screens/add_quote/step_chip.dart";
import "package:kwotes/types/topic.dart";
import "package:wave_divider/wave_divider.dart";

class AddQuoteTopicPage extends StatelessWidget {
  const AddQuoteTopicPage({
    super.key,
    required this.topics,
    required this.saveButton,
    this.isDark = false,
    this.isMobileSize = false,
    this.onClearTopic,
    this.onSelected,
    this.onDeleteQuote,
    this.onToggleCategory,
    this.categories = const [],
    this.appBarRightChildren = const [],
  });

  /// Use dark mode if true.
  final bool isDark;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Callback fired when a topic is tapped.
  final void Function(Topic topic, bool selected)? onSelected;

  final void Function(String category, bool selected)? onToggleCategory;

  /// Callback fired when "Clear topics" button is tapped.
  final void Function()? onClearTopic;

  /// Callback fired to delete the quote we're editing.
  final void Function()? onDeleteQuote;

  /// List of categories (e.g. "Movies", "Music", "Series").
  final List<String> categories;

  /// List of topics.
  final List<Topic> topics;

  /// Right children of the application bar.
  final List<Widget> appBarRightChildren;

  /// Save draft quote button.
  final Widget saveButton;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverPadding(
          padding: isMobileSize
              ? const EdgeInsets.only(
                  top: 24.0,
                  left: 24.0,
                  right: 24.0,
                  bottom: 190.0,
                )
              : const EdgeInsets.only(
                  left: 48.0,
                  right: 54.0,
                  top: 24.0,
                  bottom: 240.0,
                ),
          sliver: SliverList.list(children: [
            Center(
              child: StepChip(
                currentStep: 2,
                isDark: isDark,
              ),
            ),
            Center(
              child: Text(
                "caracterization".tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: isMobileSize ? 24.0 : 42.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 600.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    "quote.add_topics".tr(),
                    textAlign: TextAlign.center,
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: isMobileSize ? 16.0 : 24.0,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const WaveDivider(),
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                width: 600.0,
                child: Text(
                  "category.names".tr(),
                  textAlign: TextAlign.center,
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: isMobileSize ? 16.0 : 24.0,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700.0),
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    alignment: WrapAlignment.center,
                    children: categories.map((String category) {
                      final bool selected = NavigationStateHelper
                          .quote.categories
                          .any((x) => x == category);

                      return ChoiceChip(
                        selected: selected,
                        selectedColor: Constants.colors.pastelPalette.elementAt(
                          category.hashCode %
                              Constants.colors.pastelPalette.length,
                        ),
                        onSelected: (bool newSelected) =>
                            onToggleCategory?.call(category, newSelected),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(
                            color: foregroundColor?.withOpacity(0.2) ??
                                Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        label: Text(
                          "${category.characters.first.toUpperCase()}${category.substring(1)}",
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const WaveDivider(
              padding: EdgeInsets.symmetric(vertical: 24.0),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                width: 600.0,
                child: Text(
                  "topics.name".tr(),
                  textAlign: TextAlign.center,
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: isMobileSize ? 16.0 : 24.0,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  alignment: WrapAlignment.center,
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
              ),
            ),
            Center(
              child: SizedBox(
                width: 700.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 1.0,
                        child: Divider(
                          thickness: 1.2,
                          height: 24.0,
                          color: foregroundColor?.withOpacity(0.2) ??
                              Colors.black38,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            TextButton(
                              onPressed: onClearTopic,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.pink.shade100,
                                foregroundColor: Colors.pink,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 14.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(TablerIcons.clear_all),
                                  ),
                                  Text("quote.clear_topics".tr()),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: saveButton,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
