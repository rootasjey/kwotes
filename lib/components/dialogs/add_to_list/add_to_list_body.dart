import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_item.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote_list.dart";

class AddToListBody extends StatelessWidget {
  /// Body component for [AddToListDialog] parent component.
  const AddToListBody({
    super.key,
    required this.pageScrollController,
    this.selectedColor,
    this.pageState = EnumPageState.idle,
    this.onScroll,
    this.quoteLists = const [],
    this.maxHeight = 300.0,
    this.maxWidth = 300.0,
    this.onTapListItem,
    this.onLongPressListItem,
    this.selectedQuoteLists = const [],
  });

  /// Selected list color.
  final Color? selectedColor;

  /// Dialog's body max height.
  final double maxHeight;

  /// Dialog's body max width.
  final double maxWidth;

  /// Scroll controller.
  final ScrollController pageScrollController;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// On scroll callback.
  final void Function(double)? onScroll;

  /// Callback fired when a quote list is tapped.
  final void Function(QuoteList quoteList)? onTapListItem;

  /// Callback fired when a quote list is long pressed.
  final void Function(QuoteList quoteList)? onLongPressListItem;

  /// List of quote lists.
  final List<QuoteList> quoteLists;

  /// Selected quote lists to add quote(s) to.
  final List<QuoteList> selectedQuoteLists;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        useSliver: false,
        message: "loading".tr(),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        maxWidth: maxWidth,
      ),
      child: ImprovedScrolling(
        onScroll: onScroll,
        scrollController: pageScrollController,
        child: ScrollConfiguration(
          behavior: const CustomScrollBehavior(),
          child: CustomScrollView(
            controller: pageScrollController,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final QuoteList quoteList = quoteLists.elementAt(index);
                    return AddToListItem(
                      quoteList: quoteList,
                      onTap: onTapListItem,
                      selected: selectedQuoteLists.contains(quoteList),
                      selectedColor: selectedColor,
                      onLongPress: onLongPressListItem,
                    );
                  },
                  childCount: quoteLists.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
