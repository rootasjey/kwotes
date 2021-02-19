enum AddQuoteType {
  draft,
  offline,
  tempquote,
  pubQuote,
}

enum AniProps {
  color,
  height,
  opacity,
  translateX,
  translateY,
  width,
}

enum AppBarDevelopers {
  apiReference,
  apiStatus,
  documentation,
  github,
  portal,
}

enum AppBarDiscover {
  authors,
  references,
  random,
}

enum AppBarGroupedSectionItems {
  github,
  authors,
  references,
  random,
  about,
  contact,
  tos,
}

enum AppBarResources {
  about,
  androidApp,
  contact,
  iosApp,
  tos,
}

enum AppBarQuotesBy {
  authors,
  references,
  topics,
}

enum AppBarSettings {
  allSettings,
  selectLang,
  en,
  fr,
}

enum DiscoverType {
  authors,
  references,
}

/// Gives information on data type we're editing
/// on [addquote/author] page.
enum EditAuthorMode {
  /// Adding author data along side a new quote.
  addQuote,

  /// Edit an author independently.
  editAuthor,
}

/// Game lifecycle.
enum GameState {
  /// The game hasn't started yet.
  stopped,

  /// The game is currently running.
  running,

  /// The game is paused. It can either be resumed or finished.
  paused,

  /// Te game is finished.
  finished,
}

enum HeaderViewType {
  options,
  search,
}

enum ImageShareColor {
  dark,
  light,
  colored,
  gradient,
}

enum ImageShareTextColor {
  auto,
  dark,
  light,
}

enum ItemsLayout {
  list,
  grid,
}

enum ItemComponentType {
  card,
  verticalCard,
  row,
}

enum QuotePageType {
  favourites,
  list,
  published,
}

enum ScreenLayout {
  wide,
  small,
}

enum SnackType {
  error,
  info,
  success,
}

enum TempQuoteUIActionType {
  delete,
  validate,
}
