import "package:flutter/material.dart";
import "package:kwotes/components/texts/quote_text.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/quote.dart";

class DraftQuoteText extends StatelessWidget {
  /// A component to display a draft quote as its text.
  /// Base class: Quote.
  const DraftQuoteText({
    super.key,
    required this.draftQuote,
    required this.margin,
    this.onTap,
  });

  /// Main data.
  final DraftQuote draftQuote;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when draft quote is tapped.
  final void Function(DraftQuote draftQuote)? onTap;

  @override
  Widget build(BuildContext context) {
    return QuoteText(
      key: key,
      quote: draftQuote,
      margin: margin,
      onTap: (Quote quote) => onTap?.call(draftQuote),
    );
  }
}
