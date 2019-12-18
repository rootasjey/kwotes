class AddQuoteInputs {
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
  static String refPromoUrl = '';
  static String refUrl      = '';

  static String comment = '';

  static bool isCompleted = false;
  static bool hasExceptions = false;

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

 static void clearQuoteName() {
    name = '';
  }

  static void clearReference() {
    refImgUrl   = '';
    refLang     = 'en';
    refName     = '';
    refSummary  = '';
    refType     = '';
    refSubType  = '';
    refPromoUrl = '';
    refUrl      = '';
  }

  static void clearStatus() {
    isCompleted = false;
    hasExceptions = false;
  }

  static void clearTopics() {
    topics.clear();
  }
}
