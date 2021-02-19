import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/types/temp_quote.dart';

class DataQuoteInputs {
  /// If not empty, the author already exists.
  static Author author = Author.empty();

  static String comment = '';
  static TempQuote draft;

  /// True if it's a published quote that's being edited.
  static bool isEditingPubQuote = false;

  /// True if it's a draft quote that's being edited.
  static bool isOfflineDraft = false;

  /// Quote's id is not empty if this is an edit.
  static Quote quote = Quote.empty();

  /// If not empty, the reference already exists.
  static Reference reference = Reference.empty();

  static String region = '';

  static void clearAll() {
    isEditingPubQuote = false;
    isOfflineDraft = false;

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

    author = tempQuote.author;
    reference = tempQuote.reference;

    if (tempQuote.comments.length > 0) {
      comment = tempQuote.comments.first;
    } else {
      comment = '';
    }

    region = tempQuote.region;
  }
}
