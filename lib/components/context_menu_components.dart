import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/globals/utils.dart";
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
        MenuAction(
          title: "quote.share.link".tr(),
          image: MenuImage.icon(TablerIcons.link),
          callback: () => onShareLink?.call(quote),
        ),
        MenuAction(
          title: "quote.share.text".tr(),
          image: MenuImage.icon(TablerIcons.text_caption),
          callback: () => onShareText?.call(quote),
        ),
        MenuAction(
          title: "quote.share.image".tr(),
          image: MenuImage.icon(TablerIcons.photo_share),
          callback: () => onShareImage?.call(quote),
        ),
      ],
    );
  }
}
