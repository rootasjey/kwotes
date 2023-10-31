import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/screens/search/search_author_results_page.dart";
import "package:kwotes/screens/search/search_quote_results_page.dart";
import "package:kwotes/screens/search/search_reference_results_page.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_search_category.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";

class SearchPageBody extends StatelessWidget {
  const SearchPageBody({
    super.key,
    this.pageState = EnumPageState.idle,
    this.quoteResults = const [],
    this.margin = EdgeInsets.zero,
    this.isQueryEmpty = true,
    this.searchCategory = EnumSearchCategory.quote,
    this.authorResults = const [],
    this.onTapAuthor,
    this.onTapReference,
    this.onTapQuote,
    this.referenceResults = const [],
  });

  /// True if the search query is empty.
  /// Don't show empty result message if this is true.
  final bool isQueryEmpty;

  /// Page's state (e.g. searching, idle, ...).
  final EnumPageState pageState;

  /// List of quote results.
  final List<Quote> quoteResults;

  /// List of author results.
  final List<Author> authorResults;

  /// List of reference results.
  final List<Reference> referenceResults;

  /// Space around this widget.
  final EdgeInsets margin;

  /// The specific category we are searching.
  final EnumSearchCategory searchCategory;

  /// Callback fired when author name is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when reference name is tapped.
  final void Function(Reference reference)? onTapReference;

  /// Callback fired when quote name is tapped.
  final void Function(Quote quote)? onTapQuote;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading ||
        pageState == EnumPageState.searching) {
      return LoadingView(
        message: "search.ing".tr(),
      );
    }

    if (quoteResults.isEmpty &&
        authorResults.isEmpty &&
        referenceResults.isEmpty &&
        !isQueryEmpty) {
      return EmptyView(
        margin: margin,
        description: "search.empty_quotes".tr(),
      );
    }

    if (searchCategory == EnumSearchCategory.quote) {
      return SearchQuoteResultsPage(
        margin: margin,
        quoteResults: quoteResults,
        onTapQuote: onTapQuote,
      );
    }

    if (searchCategory == EnumSearchCategory.author) {
      return SearchAuthorResultsPage(
        margin: margin,
        authorResults: authorResults,
        onTapAuthor: onTapAuthor,
      );
    }

    return SearchReferenceResultsPage(
      margin: margin,
      referenceResults: referenceResults,
      onTapReference: onTapReference,
    );
  }
}
