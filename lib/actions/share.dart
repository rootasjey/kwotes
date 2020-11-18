import 'package:figstyle/screens/image_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/reference.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

void shareAuthor({@required BuildContext context, @required Author author}) {
  if (kIsWeb) {
    shareAuthorWeb(author: author);
    return;
  }

  shareAuthorMobile(context: context, author: author);
}

void shareAuthorMobile({
  @required BuildContext context,
  @required Author author,
}) {
  final RenderBox box = context.findRenderObject();
  String sharingText = author.name;
  final urlReference = 'https://outofcontext.app/#/reference/${author.id}';

  if (author.job != null && author.job.isNotEmpty) {
    sharingText += ' (${author.job})';
  }

  sharingText += ' - URL: $urlReference';

  Share.share(
    sharingText,
    subject: 'fig.style',
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
  );
}

void shareAuthorWeb({@required Author author}) async {
  String sharingText = author.name;
  final urlReference = 'https://outofcontext.app/#/reference/${author.id}';

  if (author.job != null && author.job.isNotEmpty) {
    sharingText += ' (${author.job})';
  }

  final hashtags = '&hashtags=outofcontext';

  await launch(
    'https://twitter.com/intent/tweet?via=outofcontextapp&text=$sharingText$hashtags&url=$urlReference',
  );
}

void shareQuote({@required BuildContext context, @required Quote quote}) {
  if (kIsWeb) {
    shareQuoteWeb(quote: quote);
    return;
  }

  shareQuoteMobile(quote: quote, context: context);
}

void shareQuoteMobile({@required BuildContext context, @required Quote quote}) {
  showCustomModalBottomSheet(
    context: context,
    builder: (context, controller) {
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
              title: Text('Image'),
              trailing: Icon(Icons.image_outlined),
              onTap: () {
                Navigator.of(context).pop();

                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context, scrollController) => ImageShare(
                    quote: quote,
                    scrollController: scrollController,
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

void shareTextMobile({@required BuildContext context, @required Quote quote}) {
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

/// Sahre the target quote to twitter.
Future shareQuoteWeb({@required Quote quote}) async {
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

  final hashtags = '&hashtags=outofcontext';

  final url =
      'https://twitter.com/intent/tweet?via=outofcontextapp&text=$sharingText$hashtags';
  await launch(url);
}

void shareReference(
    {@required BuildContext context, @required Reference reference}) {
  if (kIsWeb) {
    shareReferenceWeb(context: context, reference: reference);
    return;
  }

  shareReferenceMobile(context: context, reference: reference);
}

void shareReferenceWeb(
    {@required BuildContext context, @required Reference reference}) async {
  String sharingText = reference.name;
  final urlReference = 'https://outofcontext.app/#/reference/${reference.id}';

  if (reference.type.primary.isNotEmpty) {
    sharingText += ' (${reference.type.primary})';
  }

  final hashtags = '&hashtags=outofcontext';

  await launch(
    'https://twitter.com/intent/tweet?via=outofcontextapp&text=$sharingText$hashtags&url=$urlReference',
  );
}

void shareReferenceMobile(
    {@required BuildContext context, @required Reference reference}) {
  final RenderBox box = context.findRenderObject();
  String sharingText = reference.name;
  final urlReference = 'https://outofcontext.app/#/reference/${reference.id}';

  if (reference.type.primary.isNotEmpty) {
    sharingText += ' (${reference.type.primary})';
  }

  sharingText += ' - URL: $urlReference';

  Share.share(
    sharingText,
    subject: 'fig.style',
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
  );
}
