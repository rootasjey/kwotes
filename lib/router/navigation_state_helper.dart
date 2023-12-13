import "package:flutter/widgets.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_frame_border_style.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/quote_list.dart";
import "package:kwotes/types/reference.dart";

/// Helper class which contains additional navigation states.
class NavigationStateHelper {
  /// Last image selected.
  /// This should be affected before navigating to EditImagePage.
  /// This state's property allow us to pass image data
  /// outside the page's state (because of the router behavior).
  static ImageProvider<Object>? imageToEdit;

  /// Selected author and passed through author page.
  static Author author = Author.empty();

  /// Show quote page in fullscreen (hiding the navigation bar) if true.
  /// We need this property on top of the local storage
  /// in order to syncronously know where to navigate (with the router).
  static bool fullscreenQuotePage = true;

  /// App frame border style.
  static EnumFrameBorderStyle frameBorderStyle = EnumFrameBorderStyle.discrete;

  /// Hide duplicated actions (e.g. [close], [copy]) on quote page,
  /// if this is true.
  static bool minimalQuoteActions = false;

  /// Random quotes for home page.
  static List<Quote> randomQuotes = [];

  /// Latest added authors.
  static List<Author> latestAddedAuthors = [];

  /// Latest added references.
  static List<Reference> latestAddedReferences = [];

  /// Selected reference and passed through reference page.
  static Reference reference = Reference.empty();

  /// Selected quote and passed through quote page.
  static Quote quote = Quote.empty();

  /// Selected quote list and passed through quote list page.
  static QuoteList quoteList = QuoteList.empty();

  /// Last random quote language.
  /// Useful for fetching new random quotes after a language change.
  static String lastRandomQuoteLanguage = "en";

  /// Last topic name.
  static String lastTopicName = "";

  /// Search value.
  /// This value will be passed to the search page on navigation.
  /// Thus keeping context when navigating back and forth result pages.
  static String searchValue = "";
}
