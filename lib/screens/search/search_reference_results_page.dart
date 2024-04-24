import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/reference.dart";
import "package:wave_divider/wave_divider.dart";

/// Wraped text results for references.
class SearchReferenceResultsPage extends StatelessWidget {
  const SearchReferenceResultsPage({
    super.key,
    this.isMobileSize = false,
    this.isQueryEmpty = true,
    this.margin = EdgeInsets.zero,
    this.onTapReference,
    this.onRefreshSearch,
    this.onReinitializeSearch,
    this.referenceResults = const [],
  });

  /// True if this is a mobile size.
  /// Used to determine the size of the search input.
  final bool isMobileSize;

  /// True if the search query is empty.
  /// Show empty result message if this is true.
  final bool isQueryEmpty;

  /// Space around this widget.
  final EdgeInsets margin;

  /// List of reference results.
  final List<Reference> referenceResults;

  /// Callback fired to refresh the search.
  final void Function()? onRefreshSearch;

  /// Callback fired to reinit the search.
  final void Function()? onReinitializeSearch;

  /// Callback fired when author name is tapped.
  final void Function(Reference reference)? onTapReference;
  @override
  Widget build(BuildContext context) {
    if (referenceResults.isEmpty && !isQueryEmpty) {
      return EmptyView.searchEmptyView(
        accentColor: Theme.of(context).colorScheme.secondary,
        context,
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
        description: "search.empty.references".tr(),
        margin: margin,
        onReinitializeSearch: onReinitializeSearch,
        onRefresh: onRefreshSearch,
        title: "search.empty.results".tr(),
      );
    }

    return SliverPadding(
      padding: margin.subtract(const EdgeInsets.only(left: 12.0)),
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
          final Reference reference = referenceResults[index];
          return Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onTapReference?.call(reference),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text(
                reference.name,
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
        itemCount: referenceResults.length,
      ),
    );
  }
}
