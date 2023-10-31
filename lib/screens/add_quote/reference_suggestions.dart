import "package:flutter/material.dart";
import "package:kwotes/screens/add_quote/reference_suggestion_column.dart";
import "package:kwotes/screens/add_quote/reference_suggestion_row.dart";
import "package:kwotes/types/reference.dart";

class ReferenceSuggestions extends StatelessWidget {
  /// A component for displaying reference suggestions when typing characters.
  const ReferenceSuggestions({
    super.key,
    required this.references,
    required this.selectedReference,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.onTapSuggestion,
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Reference suggestions.
  final List<Reference> references;

  /// Callback fired when a suggestion is tapped.
  final void Function(Reference reference)? onTapSuggestion;

  /// Currently selected reference.
  final Reference selectedReference;

  @override
  Widget build(BuildContext context) {
    if (isMobileSize) {
      return ReferenceSuggestionColumn(
        margin: margin,
        onTapSuggestion: onTapSuggestion,
        references: references,
        selectedReference: selectedReference,
      );
    }

    return ReferenceSuggestionRow(
      margin: margin,
      onTapSuggestion: onTapSuggestion,
      references: references,
      selectedReference: selectedReference,
    );
  }
}
