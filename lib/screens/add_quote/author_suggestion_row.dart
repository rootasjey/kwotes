import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

class AuthorSuggestionRow extends StatelessWidget {
  /// A component for displaying author suggestions.
  const AuthorSuggestionRow({
    super.key,
    required this.selectedAuthor,
    this.margin = const EdgeInsets.only(top: 8.0, bottom: 24.0),
    this.onTapSuggestion,
    this.authors = const [],
  });

  /// Currently selected author.
  final Author selectedAuthor;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Author suggestions.
  final List<Author> authors;

  /// Callback fired when a suggestion is tapped.
  final void Function(Author author)? onTapSuggestion;

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          SizedBox(
            height: 42.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    "${"suggestions".tr()}:",
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    final Author author = authors[index];
                    final bool selected = selectedAuthor.id == author.id;

                    return Tooltip(
                      message: author.name,
                      child: BetterAvatar(
                        margin: const EdgeInsets.only(right: 8.0),
                        radius: 16.0,
                        selected: selected,
                        borderColor: Constants.colors.foregroundPalette.first,
                        onTap: () => onTapSuggestion?.call(author),
                        imageProvider: NetworkImage(
                          author.urls.image,
                        ),
                      ),
                    );
                  },
                  itemCount: authors.length,
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
