import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/draft_quote.dart";
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

  /// A context menu for draft quotes.
  static FutureOr<Menu?> draftMenuProvider(
    BuildContext context, {
    required DraftQuote draftQuote,
    void Function(DraftQuote quote)? onCopyFrom,
    void Function(DraftQuote quote)? onDelete,
    void Function(DraftQuote quote)? onEdit,
    void Function(DraftQuote quote)? onSubmit,
  }) {
    return Menu(children: [
      if (onDelete != null)
        MenuAction(
          callback: () => onDelete.call(draftQuote),
          title: "quote.delete.draft".tr(),
          image: MenuImage.icon(TablerIcons.trash),
          attributes: const MenuActionAttributes(destructive: true),
        ),
      if (onCopyFrom != null)
        MenuAction(
          callback: () => onCopyFrom.call(draftQuote),
          title: "${"quote.copy_from.name".tr()}...",
          image: MenuImage.icon(TablerIcons.copy),
        ),
      if (onEdit != null)
        MenuAction(
          callback: () => onEdit.call(draftQuote),
          title: "quote.edit.draft".tr(),
          image: MenuImage.icon(TablerIcons.edit),
        ),
      if (onSubmit != null)
        MenuAction(
          callback: () => onSubmit.call(draftQuote),
          title: "quote.submit.name".tr(),
          image: MenuImage.icon(TablerIcons.send),
        ),
    ]);
  }

  /// A context menu for quotes.
  static FutureOr<Menu?> quoteMenuProvider(
    BuildContext context, {
    required Quote quote,
    Color? selectedColor,
    void Function(Quote quote)? onCopyQuote,
    void Function(Quote quote)? onCopyQuoteUrl,
    void Function(Quote quote, String newLanguage)? onChangeLanguage,
    void Function(Quote quote)? onShareImage,
    void Function(Quote quote)? onShareLink,
    void Function(Quote quote)? onShareText,
    void Function(Quote quote)? onDelete,
    void Function(Quote quote)? onEdit,
    void Function(Quote quote)? onRemoveFromFavourites,
    void Function(Quote quote)? onRemoveFromList,
    String userId = "",
  }) {
    final bool authenticated = userId.isNotEmpty;
    final bool canShare =
        onShareImage != null || onShareLink != null || onShareText != null;

    final bool showAuthSeparator =
        authenticated || canShare || onRemoveFromFavourites != null;

    final bool showAdminSeparator =
        (onChangeLanguage != null || onDelete != null || onEdit != null) &&
            (authenticated || canShare);

    return Menu(children: [
      MenuAction(
        callback: () => onCopyQuote?.call(quote),
        title: "quote.copy.name".tr(),
        image: MenuImage.icon(TablerIcons.blockquote),
      ),
      if (onCopyQuoteUrl != null)
        MenuAction(
          callback: () => onCopyQuoteUrl.call(quote),
          title: "quote.copy.link".tr(),
          image: MenuImage.icon(TablerIcons.link),
        ),
      if (showAuthSeparator) MenuSeparator(),
      if (onRemoveFromFavourites != null)
        MenuAction(
          callback: () => onRemoveFromFavourites.call(quote),
          title: "quote.favourite.remove.name".tr(),
          image: MenuImage.icon(TablerIcons.heart_minus),
        ),
      if (onRemoveFromList != null)
        MenuAction(
          title: "list.remove.quote".tr(),
          callback: () => onRemoveFromList.call(quote),
          image: MenuImage.icon(TablerIcons.square_rounded_minus),
        ),
      if (authenticated)
        addToList(
          context,
          quote: quote,
          selectedColor: selectedColor,
          userId: userId,
        ),
      if (canShare)
        share(
          context,
          quote: quote,
          onShareImage: onShareImage,
          onShareLink: onShareLink,
          onShareText: onShareText,
        ),
      if (showAdminSeparator) MenuSeparator(),
      if (onChangeLanguage != null)
        changeLanguage(
          context,
          quote: quote,
          onChangeLanguage: onChangeLanguage,
        ),
      if (onDelete != null)
        MenuAction(
          callback: () => onDelete.call(quote),
          title: "quote.delete.name".tr(),
          image: MenuImage.icon(TablerIcons.trash),
        ),
      if (onEdit != null)
        MenuAction(
          callback: () => onEdit.call(quote),
          title: "quote.edit.name".tr(),
          image: MenuImage.icon(TablerIcons.edit),
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
