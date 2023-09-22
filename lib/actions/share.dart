import "package:beamer/beamer.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:kwotes/screens/image_share.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";

/// Interface for share to external sources.
class ShareActions {
  static void shareAuthor({
    required BuildContext context,
    required Author author,
  }) {
    if (kIsWeb) {
      shareAuthorWeb(author: author);
      return;
    }

    shareAuthorMobile(
      context: context,
      author: author,
    );
  }

  static void shareAuthorMobile({
    required BuildContext context,
    required Author author,
  }) {
    // final RenderObject? box = context.findRenderObject();
    // String sharingText = author.name;
    // final authorUrl = "${Constants.authorUrl}/${author.id}";

    // if (author.job.isNotEmpty) {
    //   sharingText += " (${author.job})";
    // }

    // sharingText += " - URL: $authorUrl";

    // Share.share(
    //   sharingText,
    //   subject: "kwotes",
    //   // sharePositionOrigin: box?.localToGlobal(Offset.zero) & box?.size,
    // );
  }

  static void shareAuthorWeb({required Author author}) async {
    // String sharingText = author.name;
    // final authorUrl = "${Constants.authorUrl}/${author.id}";

    // if (author.job.isNotEmpty) {
    //   sharingText += " (${author.job})";
    // }

    // final hashtags = Constants.twitterShareHashtags;

    // await launch(
    //   "${Constants.baseTwitterShareUrl}"
    //   "$sharingText"
    //   "$hashtags"
    //   "&url=$authorUrl",
    // );
  }

  static void shareQuote({
    required BuildContext context,
    required Quote quote,
  }) {
    if (kIsWeb) {
      ShareActions.shareQuoteWeb(quote: quote);
      return;
    }

    shareQuoteMobile(
      quote: quote,
      context: context,
    );
  }

  static void shareQuoteMobile({
    required BuildContext context,
    required Quote quote,
  }) {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                title: const Text("Text"),
                trailing: const Icon(
                  Icons.text_fields_rounded,
                ),
                onTap: () {
                  Beamer.of(context).popRoute();
                  shareTextMobile(context: context, quote: quote);
                },
              ),
              ListTile(
                title: const Text("Link"),
                trailing: const Icon(
                  Icons.link,
                ),
                onTap: () {
                  Beamer.of(context).popRoute();
                  shareLinkMobile(context: context, quote: quote);
                },
              ),
              ListTile(
                title: const Text("Image"),
                trailing: const Icon(Icons.image_outlined),
                onTap: () {
                  Beamer.of(context).popRoute();

                  showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => ImageShare(
                      quote: quote,
                      scrollController: ModalScrollController.of(context),
                    ),
                  );
                },
              ),
            ]),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(12.0),
              child: child,
            ),
          ),
        );
      },
    );
  }

  static void shareTextMobile({
    required BuildContext context,
    required Quote quote,
  }) {
    // final RenderObject? box = context.findRenderObject();
    // final quoteName = quote.name;
    // final authorName = quote.author.name;
    // final referenceName = quote.reference.name;

    // String sharingText = quoteName;

    // if (authorName.isNotEmpty) {
    //   sharingText += " — $authorName";
    // }

    // if (referenceName.isNotEmpty) {
    //   sharingText += " — $referenceName";
    // }

    // Share.share(
    //   sharingText,
    //   subject: "fig.style",
    //   sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    // );
  }

  static void shareLinkMobile({
    required BuildContext context,
    required Quote quote,
  }) {
    // final RenderObject? box = context.findRenderObject();
    // final sharingText = "${Constants.quoteUrl}/${quote.id}";

    // Share.share(
    //   sharingText,
    //   subject: "fig.style",
    //   sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    // );
  }

  /// Sahre the target quote to twitter.
  static Future shareQuoteWeb({required Quote quote}) async {
    // final quoteName = quote.name;
    // final authorName = quote.author.name;
    // final referenceName = quote.reference.name;

    // String sharingText = quoteName;

    // if (authorName.isNotEmpty) {
    //   sharingText += " — $authorName";
    // }

    // if (referenceName != null && referenceName.length > 0) {
    //   sharingText += " — $referenceName";
    // }

    // final hashtags = Constants.twitterShareHashtags;

    // final url = "&url=${Constants.baseQuoteUrl}${quote.id}";

    // await launch(
    //   "${Constants.baseTwitterShareUrl}"
    //   "$sharingText"
    //   "$hashtags"
    //   "$url",
    // );
  }

  static void shareReference({
    required BuildContext context,
    required Reference reference,
  }) {
    if (kIsWeb) {
      shareReferenceWeb(
        context: context,
        reference: reference,
      );
      return;
    }

    shareReferenceMobile(
      context: context,
      reference: reference,
    );
  }

  static void shareReferenceWeb({
    required BuildContext context,
    required Reference reference,
  }) async {
    // String sharingText = reference.name;
    // final referenceUrl = "${Constants.referenceUrl}/${reference.id}";

    // if (reference.type.primary.isNotEmpty) {
    //   sharingText += " (${reference.type.primary})";
    // }

    // final hashtags = Constants.twitterShareHashtags;

    // await launch(
    //   "${Constants.baseTwitterShareUrl}"
    //   "$sharingText"
    //   "$hashtags"
    //   "&url=$referenceUrl",
    // );
  }

  static void shareReferenceMobile({
    required BuildContext context,
    required Reference reference,
  }) {
    // final RenderObject? box = context.findRenderObject();
    // String sharingText = reference.name;
    // final referenceUrl = "${Constants.referenceUrl}/${reference.id}";

    // if (reference.type.primary.isNotEmpty) {
    //   sharingText += " (${reference.type.primary})";
    // }

    // sharingText += " - URL: $referenceUrl";

    // Share.share(
    //   sharingText,
    //   subject: "fig.style",
    //   sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    // );
  }
}
