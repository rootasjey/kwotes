import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:wave_divider/wave_divider.dart";

/// Wraped text results for authors.
class SearchAuthorResultsPage extends StatelessWidget {
  const SearchAuthorResultsPage({
    super.key,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.authorResults = const [],
    this.onTapAuthor,
  });

  /// True if this is a mobile size.
  /// Used to determine the size of the search input.
  final bool isMobileSize;

  /// Space around this widget.
  final EdgeInsets margin;

  /// List of author results.
  final List<Author> authorResults;

  /// Callback fired when author name is tapped.
  final void Function(Author author)? onTapAuthor;

  @override
  Widget build(BuildContext context) {
    final List<Color> contrastPalette =
        Constants.colors.darkerForegroundPalette;

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
                    fontSize: isMobileSize ? 36.0 : 54.0,
                    fontWeight: FontWeight.w300,
                    color: contrastPalette[index % contrastPalette.length],
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
