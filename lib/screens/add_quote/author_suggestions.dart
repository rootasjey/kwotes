import "package:flutter/material.dart";
import "package:kwotes/screens/add_quote/author_suggestion_column.dart";
import "package:kwotes/screens/add_quote/author_suggestion_row.dart";
import "package:kwotes/types/author.dart";

class AuthorSuggestions extends StatelessWidget {
  /// A component for displaying author suggestions when typing characters.
  const AuthorSuggestions({
    super.key,
    required this.authors,
    required this.selectedAuthor,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.onTapSuggestion,
    this.onTapShowAsList,
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Reference suggestions.
  final List<Author> authors;

  /// Callback fired when a suggestion is tapped.
  final void Function(Author author)? onTapSuggestion;

  /// Callback fired when show as list button is tapped.
  final void Function()? onTapShowAsList;

  /// Currently selected author.
  final Author selectedAuthor;

  @override
  Widget build(BuildContext context) {
    if (isMobileSize) {
      return AuthorSuggestionColumn(
        margin: margin,
        onTapSuggestion: onTapSuggestion,
        authors: authors,
        selectedAuthor: selectedAuthor,
        onTapShowAsList: onTapShowAsList,
      );
    }

    return AuthorSuggestionRow(
      margin: margin,
      onTapSuggestion: onTapSuggestion,
      authors: authors,
      selectedAuthor: selectedAuthor,
      onTapShowAsList: onTapShowAsList,
    );
  }
}
