import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/reference_type.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/types/urls.dart';

class AddQuoteInputs {
  /// Navigated to new quote page
  /// from Dashboard or Admin temp quote?
  static String navigatedFromPath = '';

  /// Quote's id is not empty if this is an edit.
  static Quote quote = Quote();

  /// Draft's quote id (filled when creating a new quote).
  static String draftId = '';

  /// If not empty, the author already exists.
  static Author author = Author();

  /// If not empty, the reference already exists.
  static Reference reference = Reference();

  static String comment             = '';
  static String region              = '';

  static bool isSending             = false;
  static bool isCompleted           = false;
  static bool hasExceptions         = false;
  static String exceptionMessage    = '';

  static void clearAll() {
    clearAuthor();
    clearComment();
    clearQuoteData();
    clearReference();
    clearStatus();
    clearTopics();
  }

  static void clearAuthor() {
    author = Author();
  }

  static void clearComment() {
    comment = '';
  }

  static void clearQuoteData({bool keepLang = true}) {
    quote = Quote(
      lang: keepLang ? quote.lang : 'en',
    );
  }

  static void clearReference() {
    reference = Reference();
  }

  static void clearStatus() {
    isCompleted = false;
    hasExceptions = false;
  }

  static void clearTopics() {
    quote.topics.clear();
  }

  static populateWithTempQuote(TempQuote tempQuote) {
      quote = Quote(
        id: tempQuote.id,
        name: tempQuote.name,
        lang: tempQuote.lang,
        topics: tempQuote.topics,
      );

      author = Author(
        id      : tempQuote.author.id,
        job     : tempQuote.author.job,
        name    : tempQuote.author.name,
        summary : tempQuote.author.summary,
        urls: Urls(
          affiliate : tempQuote.author.urls.affiliate,
          amazon    : tempQuote.author.urls.amazon,
          facebook  : tempQuote.author.urls.facebook,
          image     : tempQuote.author.urls.image,
          netflix   : tempQuote.author.urls.netflix,
          primeVideo: tempQuote.author.urls.primeVideo,
          twitch    : tempQuote.author.urls.twitch,
          twitter   : tempQuote.author.urls.twitter,
          website   : tempQuote.author.urls.website,
          wikipedia : tempQuote.author.urls.wikipedia,
          youTube   : tempQuote.author.urls.youTube,
        ),
      );

      if (tempQuote.references.length > 0) {
        final ref = tempQuote.references.first;

        reference = Reference(
          id      : ref.id,
          lang    : ref.lang,
          name    : ref.name,
          summary : ref.summary,
          type    : ReferenceType(
            primary   : ref.type.primary,
            secondary : ref.type.secondary,
          ),
          urls    : Urls(
            affiliate : ref.urls.affiliate,
            facebook  : ref.urls.facebook,
            image     : ref.urls.image,
            netflix   : ref.urls.netflix,
            primeVideo: ref.urls.primeVideo,
            twitch    : ref.urls.twitch,
            twitter   : ref.urls.twitter,
            website   : ref.urls.website,
            wikipedia : ref.urls.wikipedia,
            youTube   : ref.urls.youTube,
          ),
        );
      }

      if (tempQuote.comments.length > 0) {
        comment = tempQuote.comments.first;
      }

      region = tempQuote.region;
  }
}
