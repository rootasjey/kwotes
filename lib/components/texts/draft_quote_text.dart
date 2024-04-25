import "package:flutter/material.dart";
import "package:kwotes/components/texts/quote_text.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_quote_text_magnitude.dart";
import "package:kwotes/types/quote.dart";

class DraftQuoteText extends StatelessWidget {
  /// A component to display a draft quote as its text.
  /// Base class: Quote.
  const DraftQuoteText({
    super.key,
    required this.draftQuote,
    this.contraints = const BoxConstraints(minHeight: 0),
    this.magnitude = EnumQuoteTextMagnitude.big,
    this.margin = EdgeInsets.zero,
    this.onTap,
  });

  /// Constraints for this widget.
  final BoxConstraints contraints;

  /// Main data.
  final DraftQuote draftQuote;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Predefined quote text size (e.g. `big`).
  final EnumQuoteTextMagnitude magnitude;

  /// Callback fired when draft quote is tapped.
  final void Function(DraftQuote draftQuote)? onTap;

  @override
  Widget build(BuildContext context) {
    return QuoteText(
      key: key,
      quote: draftQuote,
      margin: margin,
      magnitude: magnitude,
      constraints: contraints,
      onTap: (Quote quote) => onTap?.call(draftQuote),
    );
  }
}
