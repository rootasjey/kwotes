import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/point_in_time.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/types/temp_quote.dart';
import 'package:figstyle/types/urls.dart';

class DataQuoteInputs {
  /// If not empty, the author already exists.
  static Author author = Author.empty();

  static String comment = '';
  static TempQuote draft;

  /// True if the quote which is being is edited
  static bool isOfflineDraft = false;

  /// Quote's id is not empty if this is an edit.
  static Quote quote = Quote.empty();

  /// If not empty, the reference already exists.
  static Reference reference = Reference.empty();

  static String region = '';

  static void clearAll() {
    clearAuthor();
    clearComment();
    clearQuoteData();
    clearReference();
    clearTopics();
  }

  static void clearAuthor() {
    author = Author.empty();
  }

  static void clearComment() {
    comment = '';
  }

  static void clearQuoteData({bool keepLang = true}) {
    final prevLang = quote.lang;
    final topicsCopy = quote.topics.sublist(0);

    quote = Quote.empty();
    quote.lang = keepLang ? prevLang : 'en';
    quote.topics = topicsCopy;
    draft = null;
    isOfflineDraft = false;
  }

  static void clearReference() {
    reference = Reference.empty();
  }

  static void clearTopics() {
    quote.topics.clear();
  }

  static populateWithTempQuote(TempQuote tempQuote, {bool copy = false}) {
    String id = '';

    if (!copy) {
      id = tempQuote.id ?? '';
    }

    quote = Quote(
      id: id,
      name: tempQuote.name,
      lang: tempQuote.lang,
      topics: tempQuote.topics,
    );

    final born = tempQuote.author.born;
    final death = tempQuote.author.death;

    final tAuthor = tempQuote.author;
    final tAuthorUrls = tempQuote.author.urls;

    author = Author(
      born: born ?? PointInTime(),
      death: death ?? PointInTime(),
      id: tAuthor.id,
      isFictional: tAuthor.isFictional ?? false,
      job: tAuthor.job,
      name: tAuthor.name,
      summary: tAuthor.summary,
      urls: Urls(
        affiliate: tAuthorUrls.affiliate,
        amazon: tAuthorUrls.amazon,
        facebook: tAuthorUrls.facebook,
        image: tAuthorUrls.image,
        instagram: tAuthorUrls.instagram,
        netflix: tAuthorUrls.netflix,
        primeVideo: tAuthorUrls.primeVideo,
        twitch: tAuthorUrls.twitch,
        twitter: tAuthorUrls.twitter,
        website: tAuthorUrls.website,
        wikipedia: tAuthorUrls.wikipedia,
        youtube: tAuthorUrls.youtube,
      ),
    );

    if (tempQuote.comments.length > 0) {
      comment = tempQuote.comments.first;
    } else {
      comment = '';
    }

    region = tempQuote.region;
  }
}
