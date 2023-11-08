import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

class LatestAddedAuthors extends StatelessWidget {
  const LatestAddedAuthors({
    super.key,
    required this.authors,
    this.onTapAuthor,
    this.textColor,
  });

  /// Foreground text color.
  final Color? textColor;

  /// Callback fired when author is tapped.
  final void Function(Author author)? onTapAuthor;

  /// List of authors (main data).
  final List<Author> authors;

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "author.latest_added".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: textColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 64.0,
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemBuilder: (BuildContext context, int index) {
                final Author author = authors[index];

                if (author.urls.image.isEmpty) {
                  return BetterAvatar(
                    colorFilter: Utils.graphic.greyColorFilter,
                    imageProvider: const AssetImage(
                        "assets/images/profile-picture-avocado.png"),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    onTap: () => onTapAuthor?.call(author),
                    radius: 24.0,
                  );
                }

                return BetterAvatar(
                  colorFilter: Utils.graphic.greyColorFilter,
                  imageProvider: NetworkImage(author.urls.image),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  onTap: () => onTapAuthor?.call(author),
                  radius: 24.0,
                );
              },
              itemCount: authors.length,
              scrollDirection: Axis.horizontal,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
