import 'package:memorare/types/quote.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sahre the target quote to twitter.
Future shareTwitter({Quote quote}) async {
  final quoteName = quote.name;
  final authorName = quote.author.name;

  String quoteAndAuthor = '"$quoteName"';

  if (authorName.isNotEmpty) {
    quoteAndAuthor += ' — $authorName';
  }

  final url = 'https://twitter.com/intent/tweet?via=outofcontextapp&text=$quoteAndAuthor';
  await launch(url);
}
