import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:wave_divider/wave_divider.dart";

/// Wraped text results for authors.
class SearchAuthorResultsPage extends StatelessWidget {
  const SearchAuthorResultsPage({
    super.key,
    this.isMobileSize = false,
    this.isQueryEmpty = true,
    this.margin = EdgeInsets.zero,
    this.authorResults = const [],
    this.onRefreshSearch,
    this.onReinitializeSearch,
    this.onTapAuthor,
  });

  /// True if this is a mobile size.
  /// Used to determine the size of the search input.
  final bool isMobileSize;

  /// True if the search query is empty.
  /// Show empty result message if this is true.
  final bool isQueryEmpty;

  /// Space around this widget.
  final EdgeInsets margin;

  /// List of author results.
  final List<Author> authorResults;

  /// Callback fired to refresh the search.
  final void Function()? onRefreshSearch;

  /// Callback fired to reinit the search.
  final void Function()? onReinitializeSearch;

  /// Callback fired when author name is tapped.
  final void Function(Author author)? onTapAuthor;
  @override
  Widget build(BuildContext context) {
    if (authorResults.isEmpty && !isQueryEmpty) {
      return EmptyView.searchEmptyView(
        accentColor: Theme.of(context).colorScheme.secondary,
        context,
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
        description: "search.empty.authors".tr(),
        margin: margin,
        onReinitializeSearch: onReinitializeSearch,
        onRefresh: onRefreshSearch,
        title: "search.empty.results".tr(),
      );
    }

    return SliverPadding(
      padding: margin,
      sliver: SliverList.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: WaveDivider(
              waveHeight: 2.0,
              waveWidth: 5.0,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.2),
            ),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          final Author author = authorResults[index];
          return Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onTapAuthor?.call(author),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text(
                author.name,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: isMobileSize ? 24.0 : 54.0,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: authorResults.length,
      ),
    );
  }
}
