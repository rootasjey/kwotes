import "package:flex_list/flex_list.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/texts/showcase_text.dart";
import "package:kwotes/types/author.dart";

class ShowcaseAuthors extends StatelessWidget {
  const ShowcaseAuthors({
    super.key,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.authors = const [],
    this.onTapAuthor,
  });

  /// Adapt UI to mobile size.
  final bool isMobileSize;

  /// Space around this widget.
  final EdgeInsets margin;

  /// List of authors.
  final List<Author> authors;

  /// Callback fired when author name is tapped.
  final void Function(Author author)? onTapAuthor;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    int index = -1;

    return SliverToBoxAdapter(
      child: Padding(
        padding: margin,
        child: FlexList(
          horizontalSpacing: 6.0,
          verticalSpacing: 6.0,
          children: authors
              .map(
                (Author author) {
                  index++;
                  return ShowcaseText(
                    docId: author.id,
                    textValue: author.name,
                    isMobileSize: isMobileSize,
                    foregroundColor: index % 2 == 0
                        ? foregroundColor?.withOpacity(0.1)
                        : foregroundColor?.withOpacity(0.2),
                    onTap: onTapAuthor != null
                        ? () => onTapAuthor?.call(author)
                        : null,
                  );
                },
              )
              .toList()
              .animate(interval: 7.ms)
              .fadeIn(duration: 125.ms)
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1.0, 1.0),
              ),
        ),
      ),
    );
  }
}
