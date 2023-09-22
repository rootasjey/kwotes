import "package:flutter/material.dart";
import "package:kwotes/screens/search/showcase_authors.dart";
import "package:kwotes/screens/search/showcase_quotes.dart";
import "package:kwotes/screens/search/showcase_references.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_search_entity.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/topic.dart";

class Showcase extends StatelessWidget {
  const Showcase({
    super.key,
    this.authors = const [],
    this.references = const [],
    this.topicColors = const [],
    this.pageState = EnumPageState.idle,
    this.searchEntity = EnumSearchEntity.quote,
    this.show = true,
    this.margin = EdgeInsets.zero,
    this.onTapAuthor,
    this.onTapReference,
    this.onTapTopicColor,
  });

  /// Show or hide the showcase.
  final bool show;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Page's state (e.g. searching, idle, ...).
  final EnumPageState pageState;

  /// What type of entity we are searching.
  final EnumSearchEntity searchEntity;

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

    if (searchEntity == EnumSearchEntity.author) {
      return ShowcaseAuthors(
        margin: margin,
        authors: authors,
        onTapAuthor: onTapAuthor,
      );
    }

    if (searchEntity == EnumSearchEntity.reference) {
      return ShowcaseReferences(
        margin: margin,
        references: references,
        onTapReference: onTapReference,
      );
    }

    return ShowcaseQuotes(
      margin: margin,
      topicColors: topicColors,
      onTapTopicColor: onTapTopicColor,
    );
  }
}
