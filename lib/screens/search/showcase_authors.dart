import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/texts/showcase_text.dart";
import "package:kwotes/types/author.dart";
import "package:wave_divider/wave_divider.dart";

class ShowcaseAuthors extends StatelessWidget {
  const ShowcaseAuthors({
    super.key,
    this.isDark = false,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.authors = const [],
    this.onTapAuthor,
  });

  /// Whether dark theme is active.
  final bool isDark;

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
          final Author author = authors[index];

          return ShowcaseText(
            docId: author.id,
            isDark: isDark,
            index: index,
            initialForegroundColor: foregroundColor?.withOpacity(0.8),
            isMobileSize: isMobileSize,
            onTap: onTapAuthor != null ? () => onTapAuthor?.call(author) : null,
            textValue: author.name.toLowerCase(),
          ).animate().fadeIn(duration: 125.ms).scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1.0, 1.0),
              );
        },
        itemCount: authors.length,
      ),
    );
  }
}
