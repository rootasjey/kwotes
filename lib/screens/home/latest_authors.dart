import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

class LatestAuthors extends StatelessWidget {
  const LatestAuthors({
    super.key,
    this.margin = EdgeInsets.zero,
    this.onTapAuthor,
    this.authors = const [],
  });

  /// Space around this widget.
  final EdgeInsets margin;

  final void Function(Author author)? onTapAuthor;

  /// Authors to display.
  final List<Author> authors;

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final List<Widget> children = [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          "author.latest_added".tr(),
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              color: foregroundColor?.withOpacity(0.4),
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ];

    for (Author author in authors) {
      final image = author.urls.image.isNotEmpty
          ? NetworkImage(author.urls.image)
          : const AssetImage("assets/images/profile-picture-avocado.png");

      children.add(
        Row(
          children: [
            BetterAvatar(
              imageProvider: image as ImageProvider,
              radius: 24.0,
              margin: const EdgeInsets.only(right: 8.0),
              onTap: () => onTapAuthor?.call(author),
            ),
            Expanded(
              child: InkWell(
                onTap: () => onTapAuthor?.call(author),
                borderRadius: BorderRadius.circular(6.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    author.name,
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    children.add(
      const Padding(
        padding: EdgeInsets.only(top: 24.0),
        child: Divider(),
      ),
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: margin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
