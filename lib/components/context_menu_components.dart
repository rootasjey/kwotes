import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/quote_list.dart";
import "package:super_context_menu/super_context_menu.dart";

class ContextMenuComponents {
  /// A menu for adding a quote to a user list.
  static addToList(
    BuildContext context, {
    /// Quote data.
    required Quote quote,

    /// User's id.
    required String userId,

    /// If true, this widget will take a suitable layout for bottom sheet.
    /// Otherwise, it will have a dialog layout.
    bool isMobileSize = false,

    /// If true, the widget will show inputs to create a new list.
    bool startInCreate = false,

    /// Selected list color.
    final Color? selectedColor,
  }) {
    return Menu(
      title: "${"list.add.to".plural(1)}...",
      children: [
        MenuAction(
          title: "list.create.name".tr(),
          image: MenuImage.icon(TablerIcons.plus),
          callback: () => Utils.graphic.showAddToListDialog(
            context,
            autofocus: true,
            quotes: [quote],
            userId: userId,
            isMobileSize: isMobileSize,
            selectedColor: selectedColor,
            startInCreate: true,
          ),
        ),
        MenuSeparator(),
        MenuAction(
          title: "list.show_all.name".tr(),
          callback: () => Utils.graphic.showAddToListDialog(
            context,
            autofocus: true,
            quotes: [quote],
            userId: userId,
            isMobileSize: isMobileSize,
            selectedColor: selectedColor,
            startInCreate: false,
          ),
        ),
        MenuAction(
          callback: () => {},
          title: "recent".tr().toUpperCase(),
          image: MenuImage.icon(TablerIcons.arrow_down),
          attributes: const MenuActionAttributes(
            disabled: true,
          ),
        ),
        DeferredMenuElement(
          (_) async {
            final List<QuoteList> userQuoteLists = await UserActions.fetchLists(
              userId: userId,
            );

            return userQuoteLists.map(
              (QuoteList list) {
                return MenuAction(
                  title: list.name,
                  callback: () => UserActions.addQuoteToList(
                    userId: userId,
                    quote: quote,
                    listId: list.id,
                  ),
                );
              },
            ).toList();
          },
        ),
      ],
    );
  }

  /// A menu for changing a quote's language.
  static changeLanguage(
    BuildContext context, {
    required Quote quote,
    void Function(Quote quote, String language)? onChangeLanguage,
  }) {
    return Menu(
      title: "quote.language.change".tr(),
      image: MenuImage.icon(TablerIcons.language),
      children: Utils.linguistic.available().map(
        (EnumLanguageSelection locale) {
          return MenuAction(
            title: "language.locale.${locale.name}".tr(),
            image: quote.language == locale.name
                ? MenuImage.icon(TablerIcons.check)
                : null,
            callback: () => onChangeLanguage?.call(
              quote,
              locale.name,
            ),
          );
        },
      ).toList(),
    );
  }

  /// A context menu for authors.
  static FutureOr<Menu?> authorMenuProvider(
    BuildContext context, {
    required Author author,
    void Function(Author author)? onCopyAuthor,
    void Function(Author author)? onCopyAuthorUrl,
  }) {
    return Menu(children: [
      MenuAction(
        callback: () => onCopyAuthor?.call(author),
        title: "author.copy.name".tr(),
        image: MenuImage.icon(TablerIcons.clipboard_text),
      ),
      MenuAction(
        callback: () => onCopyAuthorUrl?.call(author),
        title: "author.copy.link".tr(),
        image: MenuImage.icon(TablerIcons.link),
      ),
    ]);
  }

  /// A context menu for quotes.
  static FutureOr<Menu?> quoteMenuProvider(
    BuildContext context, {
    required Quote quote,
    bool authenticated = false,
    Color? selectedColor,
    void Function(Quote quote)? onCopyQuote,
    void Function(Quote quote)? onCopyQuoteUrl,
    void Function(Quote quote, String newLanguage)? onChangeLanguage,
    void Function(Quote quote)? onShareImage,
    void Function(Quote quote)? onShareLink,
    void Function(Quote quote)? onShareText,
    String userId = "",
  }) {
    final bool canShare =
        onShareImage != null || onShareLink != null || onShareText != null;
    final bool showSeparator =
        authenticated || onChangeLanguage != null || canShare;

    return Menu(children: [
      MenuAction(
        callback: () => onCopyQuote?.call(quote),
        title: "quote.copy.name".tr(),
        image: MenuImage.icon(TablerIcons.blockquote),
      ),
      MenuAction(
        callback: () => onCopyQuoteUrl?.call(quote),
        title: "quote.copy.link".tr(),
        image: MenuImage.icon(TablerIcons.link),
      ),
      if (showSeparator) MenuSeparator(),
      if (authenticated)
        addToList(
          context,
          quote: quote,
          selectedColor: selectedColor,
          userId: userId,
        ),
      if (onChangeLanguage != null)
        changeLanguage(
          context,
          quote: quote,
          onChangeLanguage: onChangeLanguage,
        ),
      if (canShare)
        share(
          context,
          quote: quote,
          onShareImage: onShareImage,
          onShareLink: onShareLink,
          onShareText: onShareText,
        ),
    ]);
  }

  /// A menu fore sharing a quote.
  static share(
    BuildContext context, {
    required Quote quote,
    void Function(Quote quote)? onShareLink,
    void Function(Quote quote)? onShareText,
    void Function(Quote quote)? onShareImage,
  }) {
    return Menu(
      title: "share".tr(),
      image: MenuImage.icon(TablerIcons.share),
      children: [
        if (onShareLink != null)
          MenuAction(
            title: "quote.share.link".tr(),
            image: MenuImage.icon(TablerIcons.share_3),
            callback: () => onShareLink.call(quote),
          ),
        if (onShareText != null)
          MenuAction(
            title: "quote.share.text".tr(),
            image: MenuImage.icon(TablerIcons.message_share),
            callback: () => onShareText.call(quote),
          ),
        if (onShareImage != null)
          MenuAction(
            title: "quote.share.image".tr(),
            image: MenuImage.icon(TablerIcons.photo_share),
            callback: () => onShareImage.call(quote),
          ),
      ],
    );
  }
}
