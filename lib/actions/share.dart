import 'package:flutter/material.dart';
import 'package:memorare/types/quote.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sahre the target quote to twitter.
Future shareTwitter({Quote quote}) async {
  final quoteName = quote.name;
  final authorName = quote.author.name;

  String quoteAndAuthor = '"$quoteName"';

  if (authorName.isNotEmpty) {
    quoteAndAuthor += ' — $authorName';
  }

  final hashtags = '&hashtags=outofcontext';

  final url = 'https://twitter.com/intent/tweet?via=outofcontextapp&text=$quoteAndAuthor$hashtags';
  await launch(url);
}

void shareFromMobile({Quote quote, BuildContext context}) {
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
    subject: 'Out Of Context',
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
  );
}
