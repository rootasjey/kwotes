class AddQuoteInputs {
  /// Quote's id if this is an edit.
  static String id = '';
  static String name    = '';
  static String lang    = 'en';
  static List<String> topics  = [];

  static String authorImgUrl  = '';
  static String authorName    = '';
  static String authorJob     = '';
  static String authorSummary = '';
  static String authorUrl     = '';
  static String authorWikiUrl = '';

  static String refImgUrl   = '';
  static String refLang     = 'en';
  static String refName     = '';
  static String refSummary  = '';
  static String refType     = '';
  static String refSubType  = '';
  static String refUrl      = '';
  static String refWikiUrl  = '';

  static String comment = '';

  static bool isSending = false;
  static bool isCompleted = false;
  static bool hasExceptions = false;
  static String exceptionMessage = '';

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
    authorImgUrl  = '';
    authorName    = '';
    authorJob     = '';
    authorSummary = '';
    authorUrl     = '';
    authorWikiUrl = '';
  }

  static void clearComment() {
    comment = '';
  }

  static void clearQuoteId() {
    id = '';
  }

  static void clearQuoteName() {
    name = '';
    lang = 'en';
  }

  static void clearReference() {
    refImgUrl   = '';
    refLang     = 'en';
    refName     = '';
    refSummary  = '';
    refType     = '';
    refSubType  = '';
    refUrl = '';
    refWikiUrl      = '';
  }

  static void clearStatus() {
    isCompleted = false;
    hasExceptions = false;
  }

  static void clearTopics() {
    topics.clear();
  }
}
