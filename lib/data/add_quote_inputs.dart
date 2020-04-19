import 'package:memorare/types/author.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/reference_type.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/types/urls.dart';

class AddQuoteInputs {
  /// Navigated to new quote page
  /// from Dashboard or Admin temp quote?
  static String navigatedFromPath = '';

  /// Quote's id if this is an edit.
  static String id                  = '';
  static String name                = '';
  static String lang                = 'en';
  static List<String> topics        = [];

  /// Draft's quote id (filled when creating a new quote).
  static String draftId             = '';

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
    clearQuoteId();
    clearQuoteName();
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

  static void clearQuoteId() {
    id = '';
  }

  static void clearQuoteName() {
    name = '';
  }

  static void clearReference() {
    reference = Reference();
  }

  static void clearStatus() {
    isCompleted = false;
    hasExceptions = false;
  }

  static void clearTopics() {
    topics.clear();
  }

  static populateWithTempQuote(TempQuote tempQuote) {
      id     = tempQuote.id;
      name   = tempQuote.name;
      lang   = tempQuote.lang;
      topics = tempQuote.topics;

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
