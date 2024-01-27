import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

/// Wraped text results for authors.
class SearchAuthorResultsPage extends StatelessWidget {
  const SearchAuthorResultsPage({
    super.key,
    this.margin = EdgeInsets.zero,
    this.authorResults = const [],
    this.onTapAuthor,
  });

  /// Space around this widget.
  final EdgeInsets margin;

  /// List of author results.
  final List<Author> authorResults;

  /// Callback fired when author name is tapped.
  final void Function(Author author)? onTapAuthor;

  @override
  Widget build(BuildContext context) {
    int index = -1;
    final List<Color> contrastPalette =
        Constants.colors.darkerForegroundPalette;

    return SliverPadding(
      padding: margin.subtract(const EdgeInsets.only(left: 12.0)),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: authorResults.map((Author author) {
            index += 1;
            return TextButton(
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
                    fontSize: 54.0,
                    fontWeight: FontWeight.w300,
                    color: contrastPalette[index % contrastPalette.length],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
