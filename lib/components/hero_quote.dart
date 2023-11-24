import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";
import "package:super_context_menu/super_context_menu.dart";

class HeroQuote extends StatelessWidget {
  const HeroQuote({
    super.key,
    required this.quote,
    required this.authorMenuProvider,
    required this.quoteMenuProvider,
    this.isDark = false,
    this.isBig = false,
    this.loading = false,
    this.foregroundColor,
    this.onTapAuthor,
    this.onTapQuote,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Whether to display a big quote.
  final bool isBig;

  /// Whether to display a loading indicator.
  final bool loading;

  /// Widget background color.
  final Color? backgroundColor;

  /// Foreground text color.
  final Color? foregroundColor;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when author's name is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when author's avatar is tapped.
  final void Function(Quote quote)? onTapQuote;

  /// Context menu provider for the author.
  final FutureOr<Menu?> Function(MenuRequest menuRequest) authorMenuProvider;

  /// Context menu provider for the quote.
  final FutureOr<Menu?> Function(MenuRequest menuRequest) quoteMenuProvider;

  /// Data to display.
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingView(
        useSliver: true,
        message: "loading".tr(),
      );
    }

    final Author author = quote.author;
    final Topic topic = Constants.colors.topics.firstWhere(
      (Topic x) => x.name == quote.topics.first,
      orElse: () => Topic.empty(),
    );

    final Color accentColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: !isDark,
    );

    return SliverToBoxAdapter(
      child: Container(
        color: backgroundColor,
        padding: margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContextMenuWidget(
              menuProvider: authorMenuProvider,
              child: Material(
                color: Colors.transparent,
                child: Row(
                  children: [
                    if (author.urls.image.isNotEmpty)
                      BetterAvatar(
                        onTap: () => onTapAuthor?.call(author),
                        imageProvider: NetworkImage(author.urls.image),
                        radius: 24.0,
                      ),
                    InkWell(
                      onTap: () => onTapAuthor?.call(author),
                      splashColor: accentColor.withOpacity(0.2),
                      hoverColor: accentColor.withOpacity(0.1),
                      highlightColor: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                        child: Text(
                          "— ${quote.author.name}",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ContextMenuWidget(
              menuProvider: quoteMenuProvider,
              child: ColoredTextButton(
                onPressed: () => onTapQuote?.call(quote),
                style: TextButton.styleFrom(
                  foregroundColor: topic.color,
                  surfaceTintColor: topic.color,
                ),
                textValue: quote.name,
                textStyle: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: isBig ? 28.0 : 18.0,
                    fontWeight: isBig ? FontWeight.w200 : FontWeight.w400,
                    color: foregroundColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
