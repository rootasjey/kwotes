import "package:flutter/material.dart";
import "package:kwotes/screens/search/showcase_authors.dart";
import "package:kwotes/screens/search/showcase_quotes.dart";
import "package:kwotes/screens/search/showcase_references.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_search_category.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";

class Showcase extends StatelessWidget {
  const Showcase({
    super.key,
    this.animateItemList = false,
    this.authors = const [],
    this.references = const [],
    this.topicColors = const [],
    this.pageState = EnumPageState.idle,
    this.searchCategory = EnumSearchCategory.quotes,
    this.isDark = false,
    this.isMobileSize = false,
    this.show = true,
    this.margin = EdgeInsets.zero,
    this.onTapAuthor,
    this.onTapReference,
    this.onTapTopicColor,
  });

  /// Animate item if true.
  /// Used to skip animation while scrolling.
  final bool animateItemList;

  /// Whether dark theme is active.
  final bool isDark;

  /// Adapt UI to mobile size.
  final bool isMobileSize;

  /// Show or hide the showcase.
  final bool show;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Page's state (e.g. searching, idle, ...).
  final EnumPageState pageState;

  /// What type of entity we are searching.
  final EnumSearchCategory searchCategory;

  /// List of authors.
  final List<Author> authors;

  /// Callback fired when author name is tapped.
  final void Function(Author author)? onTapAuthor;

  /// List of references.
  final List<Reference> references;

  /// List of topic colors.
  final List<Topic> topicColors;

  /// Callback fired when reference name is tapped.
  final void Function(Reference reference)? onTapReference;

  /// Callback fired when a topic color is tapped.
  final void Function(Topic topicColor)? onTapTopicColor;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SliverToBoxAdapter();
    }

    if (searchCategory == EnumSearchCategory.authors) {
      return ShowcaseAuthors(
        animateItemList: animateItemList,
        authors: authors,
        isDark: isDark,
        isMobileSize: isMobileSize,
        margin: margin,
        onTapAuthor: onTapAuthor,
      );
    }

    if (searchCategory == EnumSearchCategory.references) {
      return ShowcaseReferences(
        animateItemList: animateItemList,
        isDark: isDark,
        isMobileSize: isMobileSize,
        margin: margin,
        references: references,
        onTapReference: onTapReference,
      );
    }

    return ShowcaseQuotes(
      animateItemList: animateItemList,
      isDark: isDark,
      isMobileSize: isMobileSize,
      margin: margin,
      topicColors: topicColors,
      onTapTopicColor: onTapTopicColor,
    );
  }
}
