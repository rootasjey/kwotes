import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/reference.dart";

/// Wraped text results for references.
class SearchReferenceResultsPage extends StatelessWidget {
  const SearchReferenceResultsPage({
    super.key,
    this.margin = EdgeInsets.zero,
    this.referenceResults = const [],
    this.onTapReference,
  });

  /// Space around this widget.
  final EdgeInsets margin;

  /// List of reference results.
  final List<Reference> referenceResults;

  /// Callback fired when author name is tapped.
  final void Function(Reference reference)? onTapReference;

  @override
  Widget build(BuildContext context) {
    int index = -1;
    final contrastPalette = Constants.colors.darkerForegroundPalette;

    return SliverPadding(
      padding: margin.subtract(const EdgeInsets.only(left: 12.0)),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: referenceResults.map((Reference reference) {
            index += 1;

            return TextButton(
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
