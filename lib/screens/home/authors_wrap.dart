import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

class AuthorsWrap extends StatelessWidget {
  const AuthorsWrap({
    super.key,
    this.isDark = false,
    this.foregroundColor,
    this.widthFactor = 1.0,
    this.heightFactor = 1.0,
    this.maxHeight = 800.0,
    this.maxWidth = 800.0,
    this.authors = const [],
    this.onTapAuthor,
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Text foreground color.
  final Color? foregroundColor;

  /// Width factor to limit this widget.
  final double widthFactor;

  /// Height factor to limit this widget.
  final double heightFactor;

  /// Max height for this widget.
  final double maxHeight;

  /// Max width for this widget.
  final double maxWidth;

  /// Authors to display.
  final List<Author> authors;

  /// Callback fired when author is tapped.
  final void Function(Author author)? onTapAuthor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            // heightFactor: heightFactor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "author.names".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 54.0,
                      color: foregroundColor,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ),
                Text(
                  "author.latest_added".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 14.0,
                      color: foregroundColor?.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Wrap(
                    children: authors
                        .map(
                          (Author author) {
                            return BetterAvatar(
                              radius: 24.0,
                              onTap: onTapAuthor != null
                                  ? () => onTapAuthor?.call(author)
                                  : null,
                              imageProvider: NetworkImage(author.urls.image),
                            );
                          },
                        )
                        .toList()
                        .animate(
                          interval: const Duration(milliseconds: 25),
                        )
                        .fadeIn(duration: const Duration(milliseconds: 150))
                        .scaleXY(begin: 0.5, end: 1.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
