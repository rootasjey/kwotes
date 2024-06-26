import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
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
    this.isDark = false,
    this.isQueryEmpty = true,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.quoteResults = const [],
    this.margin = EdgeInsets.zero,
    this.searchCategory = EnumSearchCategory.quotes,
    this.authorResults = const [],
    this.onOpenAddQuoteToList,
    this.onRefreshSearch,
    this.onReinitializeSearch,
    this.onTapAuthor,
    this.onTapReference,
    this.onTapQuote,
    this.onToggleLike,
    this.referenceResults = const [],
    this.userId = "",
  });

  /// Adapt UI for dark mode if true.
  final bool isDark;

  /// True if this is a mobile size.
  /// Used to determine the size of the search input.
  final bool isMobileSize;

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

  /// Callback fired to add a quote to a list.
  final void Function(Quote quote)? onOpenAddQuoteToList;

  /// Callback fired to refresh the search.
  final void Function()? onRefreshSearch;

  /// Callback fired to reinit the search.
  final void Function()? onReinitializeSearch;

  /// Callback fired when author name is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when reference name is tapped.
  final void Function(Reference reference)? onTapReference;

  /// Callback fired when quote name is tapped.
  final void Function(Quote quote)? onTapQuote;

  /// Callback fired to like or unlike a quote.
  final void Function(Quote quote)? onToggleLike;

  /// User ID.
  /// Used to check if user can add a quote to a list or like a quote.
  /// If user is not logged in, this will be empty.
  /// Filled otherwise.
  final String userId;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading ||
        pageState == EnumPageState.searching) {
      return LoadingView(
        message: "search.ing".tr(),
      );
    }

    if (searchCategory == EnumSearchCategory.quotes) {
      return SearchQuoteResultsPage(
        isDark: isDark,
        isMobileSize: isMobileSize,
        isQueryEmpty: isQueryEmpty,
        margin: margin,
        quoteResults: quoteResults,
        onOpenAddToList: onOpenAddQuoteToList,
        onRefreshSearch: onRefreshSearch,
        onReinitializeSearch: onReinitializeSearch,
        onTapQuote: onTapQuote,
        onToggleLike: onToggleLike,
        userId: userId,
      );
    }

    if (searchCategory == EnumSearchCategory.authors) {
      return SearchAuthorResultsPage(
        authorResults: authorResults,
        isMobileSize: isMobileSize,
        isQueryEmpty: isQueryEmpty,
        margin: margin,
        onRefreshSearch: onRefreshSearch,
        onReinitializeSearch: onReinitializeSearch,
        onTapAuthor: onTapAuthor,
      );
    }

    return SearchReferenceResultsPage(
      isMobileSize: isMobileSize,
      isQueryEmpty: isQueryEmpty,
      margin: margin,
      onRefreshSearch: onRefreshSearch,
      onReinitializeSearch: onReinitializeSearch,
      onTapReference: onTapReference,
      referenceResults: referenceResults,
    );
  }
}
