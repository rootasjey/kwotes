import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/quote_page/share_card.dart";
import "package:kwotes/types/quote.dart";
import "package:unicons/unicons.dart";

class ShareQuoteBottomSheet extends StatelessWidget {
  const ShareQuoteBottomSheet({
    super.key,
    required this.quote,
    this.onShareImage,
    this.onShareLink,
    this.onShareText,
  });

  /// Callback fired to share quote's image.
  /// [pop] indicates if the bottom sheet should be popped after sharing.
  final void Function(Quote quote, {bool pop})? onShareImage;

  /// Callback fired to share quote's link.
  final void Function(Quote quote)? onShareLink;

  /// Callback fired to share quote's text.
  final void Function(Quote quote)? onShareText;

  /// Quote data.
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets margin = EdgeInsets.all(8.0);
    final Color cardBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "quote.share.name".tr().toUpperCase(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 16.0,
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
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShareCard(
                  cardBackgroundColor: cardBackgroundColor,
                  labelValue: "text".tr(),
                  icon: const Icon(UniconsLine.text),
                  margin: margin,
                  onTap: () {
                    Navigator.of(context).pop();
                    onShareText?.call(quote);
                  },
                ),
                ShareCard(
                  cardBackgroundColor: cardBackgroundColor,
                  labelValue: "link.name".tr(),
                  icon: const Icon(TablerIcons.link),
                  margin: margin,
                  onTap: () {
                    Navigator.of(context).pop();
                    onShareLink?.call(quote);
                  },
                ),
                ShareCard(
                  cardBackgroundColor: cardBackgroundColor,
                  labelValue: "image".tr(),
                  icon: const Icon(TablerIcons.photo_share),
                  margin: margin,
                  onTap: () => onShareImage?.call(quote, pop: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
