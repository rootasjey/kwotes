import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

class AuthorSuggestionColumn extends StatelessWidget {
  /// A vertical component for displaying author suggestions
  /// when typing characters.
  const AuthorSuggestionColumn({
    super.key,
    required this.authors,
    required this.selectedAuthor,
    this.margin = EdgeInsets.zero,
    this.onTapSuggestion,
    this.onTapShowAsList,
  });

  /// Space around this widget.
  final EdgeInsets margin;

  /// Reference suggestions.
  final List<Author> authors;

  /// Callback fired when a suggestion is tapped.
  final void Function(Author author)? onTapSuggestion;

  /// Callback fired when show as list button is tapped.
  final void Function()? onTapShowAsList;

  /// Currently selected author.
  final Author selectedAuthor;

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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              "${"suggestions.name".tr()}:",
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 14.0,
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
          Row(
            children: [
              if (onTapShowAsList != null) ...[
                CircleButton(
                  icon: const Icon(TablerIcons.list, size: 18.0),
                  onTap: onTapShowAsList,
                  radius: 16.0,
                  tooltip: "suggestions.show_as_list".tr(),
                  shape: CircleBorder(
                    side: BorderSide(
                      color: Constants.colors.secondary,
                      width: 2.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    height: 12.0,
                    width: 12.0,
                    decoration: BoxDecoration(
                      color: Constants.colors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
              Expanded(
                child: SizedBox(
                  height: 42.0,
                  child: ListView.builder(
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
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
