class StorageKeys {
  const StorageKeys();

  static const String authorMetadataOpened = "author_metadata_opened";
  static const String addAuthorMetadataOpened = "add_author_metadata_opened";
  static const String addReferenceMetadataOpened =
      "add_reference_metadata_opened";
  static const String brightness = "brightness";
  static const String discoverType = "discover_type";
  static const String drafts = "drafts";
  static const String email = "email";
  static const String firstLaunch = "first_launch";

  /// Show quote page in full screen, hiding the navigation bar.
  static const String fullscreenQuotePage = "fullscreen_quote_page";
  static const String heroImageControlVivisible = "hero_image_control_visible";
  static const String homePageTabIndex = "home_page_tab_index";
  static const String myQuotesPageTabIndex = "my_quotes_page_tab_index";
  static const String frameBorderStyle = "frame_border_style";
  static const String imageShareColor = "image_share_color";
  static const String imageShareTextColor = "image_share_text_color";
  static const String itemsStyle = "items_style_";
  static const String itemsLayoutGrid = "ItemsLayout.grid";
  static const String itemsLayoutList = "ItemsLayout.list";
  static const String language = "language";
  static const String lastSearchType = "last_search_type";
  static const String onOpenNotificationPath = "on_open_notification_path";
  static const String minimalQuoteActions = "minimal_quote_actions";
  static const String notificationsActivated = "notifications_activated";
  static const String quoteIdNotification = "quote_id_notification";
  static const String referenceMetadataOpened = "reference_metadata_opened";

  /// Data ownership on certain pages (e.g. published quotes page).
  /// Can be: `owned` or `all` (users).
  static const String dataOwnership = "data_ownership";

  /// Language selection when adding/editing a new quote.
  static const String quoteLanguageSelection = "quote_language_selection";
  static const String authorQuotesLanguageSelection =
      "author_quotes_language_selection";
  static const String referenceQuotesLanguageSelection =
      "reference_quotes_language_selection";
  static const String password = "password";

  /// Selected quotes language on view pages (e.g. published quotes page).
  static const String selectedPageLanguage = "selected_quotes_language";

  /// Show header options (e.g. language, ownership) if true.
  static const String showHeaderOptions = "show_header_options";
  static const String username = "username";
  static const String userUid = "user_uid";
}
