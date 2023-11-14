import "dart:math";

import "package:boxy/slivers.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/mini_card.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";

class GridLetter extends StatelessWidget {
  const GridLetter({
    super.key,
    required this.screenSize,
    this.topBackgroundColor,
    this.onTapQuote,
    this.onCopyQuote,
    this.onCopyQuoteUrl,
  });

  /// Top background color.
  final Color? topBackgroundColor;

  /// Callback fired when a quote is tapped.
  final void Function(Quote quote)? onTapQuote;

  /// Callback fired to copy quote's content.
  final void Function(Quote quote)? onCopyQuote;

  /// Callback fired to copy quote's url. 😊
  final void Function(Quote quote)? onCopyQuoteUrl;

  /// Size of the screen.
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return SliverContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 24.0,
      ),
      background: Container(
        color: topBackgroundColor,
      ),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 64.0,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = NavigationStateHelper.randomQuotes[index];
          return ContextMenuWidget(
            child: TinyCard(
              quote: quote,
              onTap: onTapQuote,
              screenSize: screenSize,
              entranceDelay: Duration(
                milliseconds: Random().nextInt(120),
              ),
            ),
            menuProvider: (MenuRequest request) {
              return Menu(
                children: [
                  MenuAction(
                    title: "quote.copy.name".tr(),
                    image: MenuImage.icon(TablerIcons.copy),
                    callback: () => (quote),
                  ),
                  MenuAction(
                    title: "quote.copy.url".tr(),
                    image: MenuImage.icon(TablerIcons.link),
                    callback: () => onCopyQuoteUrl?.call(quote),
                  ),
                ],
              );
            },
          );
        },
        itemCount: NavigationStateHelper.randomQuotes.length,
      ),
    );
  }
}
