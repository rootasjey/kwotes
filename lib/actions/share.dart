import 'package:figstyle/screens/image_share.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/reference.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

/// Interface for share to external sources.
class ShareActions {
  static void shareAuthor({
    @required BuildContext context,
    @required Author author,
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
    @required BuildContext context,
    @required Author author,
  }) {
    final RenderBox box = context.findRenderObject();
    String sharingText = author.name;
    final authorUrl = "${Constants.baseAuthorUrl}${author.id}";

    if (author.job != null && author.job.isNotEmpty) {
      sharingText += " (${author.job})";
    }

    sharingText += " - URL: $authorUrl";

    Share.share(
      sharingText,
      subject: 'fig.style',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  static void shareAuthorWeb({@required Author author}) async {
    String sharingText = author.name;
    final authorUrl = "${Constants.baseAuthorUrl}${author.id}";

    if (author.job != null && author.job.isNotEmpty) {
      sharingText += ' (${author.job})';
    }

    final hashtags = Constants.twitterShareHashtags;

    await launch(
      "${Constants.baseTwitterShareUrl}"
      "$sharingText"
      "$hashtags"
      "&url=$authorUrl",
    );
  }

  static void shareQuote({
    @required BuildContext context,
    @required Quote quote,
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
    @required BuildContext context,
    @required Quote quote,
  }) {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                title: Text('Text'),
                trailing: Icon(
                  Icons.text_fields_rounded,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  shareTextMobile(context: context, quote: quote);
                },
              ),
              ListTile(
                title: Text('Link'),
                trailing: Icon(
                  Icons.link,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  shareLinkMobile(context: context, quote: quote);
                },
              ),
              ListTile(
                title: Text('Image'),
                trailing: Icon(Icons.image_outlined),
                onTap: () {
                  Navigator.of(context).pop();

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
    @required BuildContext context,
    @required Quote quote,
  }) {
    final RenderBox box = context.findRenderObject();
    final quoteName = quote.name;
    final authorName = quote.author?.name ?? '';
    final referenceName = quote.mainReference?.name ?? '';

    String sharingText = quoteName;

    if (authorName != null && authorName.length > 0) {
      sharingText += ' — $authorName';
    }

    if (referenceName != null && referenceName.length > 0) {
      sharingText += ' — $referenceName';
    }

    Share.share(
      sharingText,
      subject: 'fig.style',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  static void shareLinkMobile({
    @required BuildContext context,
    @required Quote quote,
  }) {
    final RenderBox box = context.findRenderObject();

    String sharingText = "${Constants.baseQuoteUrl}${quote.id}";

    Share.share(
      sharingText,
      subject: 'fig.style',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  /// Sahre the target quote to twitter.
  static Future shareQuoteWeb({@required Quote quote}) async {
    final quoteName = quote.name;
    final authorName = quote.author?.name ?? '';
    final referenceName = quote.mainReference?.name ?? '';

    String sharingText = quoteName;

    if (authorName.isNotEmpty) {
      sharingText += ' — $authorName';
    }

    if (referenceName != null && referenceName.length > 0) {
      sharingText += ' — $referenceName';
    }

    final hashtags = Constants.twitterShareHashtags;

    await launch(
      "${Constants.baseTwitterShareUrl}"
      "$sharingText"
      "$hashtags",
    );
  }

  static void shareReference({
    @required BuildContext context,
    @required Reference reference,
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
    @required BuildContext context,
    @required Reference reference,
  }) async {
    String sharingText = reference.name;
    final referenceUrl = '${Constants.baseReferenceUrl}${reference.id}';

    if (reference.type.primary.isNotEmpty) {
      sharingText += ' (${reference.type.primary})';
    }

    final hashtags = Constants.twitterShareHashtags;

    await launch(
      "${Constants.baseTwitterShareUrl}"
      "$sharingText"
      "$hashtags"
      "&url=$referenceUrl",
    );
  }

  static void shareReferenceMobile({
    @required BuildContext context,
    @required Reference reference,
  }) {
    final RenderBox box = context.findRenderObject();
    String sharingText = reference.name;
    final referenceUrl = '${Constants.baseReferenceUrl}${reference.id}';

    if (reference.type.primary.isNotEmpty) {
      sharingText += ' (${reference.type.primary})';
    }

    sharingText += ' - URL: $referenceUrl';

    Share.share(
      sharingText,
      subject: 'fig.style',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }
}
