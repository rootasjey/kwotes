import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/quote_list_text.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote_list.dart";
import "package:super_context_menu/super_context_menu.dart";

class ListsPageBody extends StatelessWidget {
  const ListsPageBody({
    super.key,
    required this.lists,
    this.animateList = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.onTap,
    this.onDeleteList,
    this.onEditList,
    this.editingListId = "",
    this.onSaveListChanges,
    this.onCancelEditListMode,
    this.onCancelDeleteList,
    this.onConfirmDeleteList,
    this.deletingListId = "",
  });

  /// Animate list's items if true.
  final bool animateList;

  /// Uses dark theme if true.
  final bool isDark;

  /// Adapt UI for mobile size.
  final bool isMobileSize;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// List of lists of quotes.
  final List<QuoteList> lists;

  /// Callback fired to delete a list.
  final void Function(QuoteList quoteList)? onDeleteList;

  /// Callback fired to edit a list.
  final void Function(QuoteList quoteList)? onEditList;

  /// Callback fired when a list is tapped.
  final void Function(QuoteList quoteList)? onTap;

  /// Callback fired to save list's changes.
  final void Function(String name, String description)? onSaveListChanges;

  /// Callback fired to cancel delete list confirmation.
  final void Function(QuoteList quoteList)? onCancelDeleteList;

  /// Callback fired to cancel edit list mode.
  final void Function()? onCancelEditListMode;

  /// Callback fired to confirm delete list.
  final void Function(QuoteList quoteList)? onConfirmDeleteList;

  /// Id of the list which is being edited.
  /// Empty if no list is being edited.
  final String editingListId;

  /// Id of the list which is being deleted.
  /// Empty if no list is being deleted.
  final String deletingListId;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "loading".tr(),
      );
    }

    return SliverPadding(
      padding: isMobileSize
          ? const EdgeInsets.only(left: 24.0, right: 24.0)
          : const EdgeInsets.only(left: 48.0, right: 72.0, top: 54.0),
      sliver: SliverList.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 54.0,
            thickness: isDark ? 2.0 : 1.0,
            color: isDark ? Colors.white12 : Colors.black12,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          final QuoteList quoteList = lists[index];
          final bool isEditing =
              (editingListId == quoteList.id) && editingListId.isNotEmpty;

          return ContextMenuWidget(
            child: QuoteListText(
              quoteList: quoteList,
              tiny: isMobileSize,
              isEditing: isEditing,
              isDeleting: deletingListId == quoteList.id,
              margin: const EdgeInsets.only(bottom: 0.0),
              onCancelEditMode: onCancelEditListMode,
              onTap: quoteList.id.isEmpty ? null : onTap,
              onSaveChanges: onSaveListChanges,
              onConfirmDelete: onConfirmDeleteList,
              onCancelDelete: onCancelDeleteList,
            )
                .animate()
                .slideY(
                  begin: 0.8,
                  duration: animateList ? 150.ms : 0.ms,
                  curve: Curves.decelerate,
                )
                .fadeIn(),
            contextMenuIsAllowed: (_) =>
                quoteList.id.isNotEmpty && editingListId != quoteList.id,
            menuProvider: (MenuRequest menuRequest) {
              return Menu(
                children: [
                  MenuAction(
                    title: "list.edit.name".tr(),
                    callback: () => onEditList?.call(quoteList),
                    image: MenuImage.icon(TablerIcons.edit),
                  ),
                  MenuAction(
                    title: "list.delete.name".tr(),
                    callback: () => onDeleteList?.call(quoteList),
                    image: MenuImage.icon(TablerIcons.trash),
                  ),
                ],
              );
            },
          );
        },
        itemCount: lists.length,
      ),
    );
  }
}
