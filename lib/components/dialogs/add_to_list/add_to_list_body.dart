import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_item.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote_list.dart";

class AddToListBody extends StatelessWidget {
  /// Body component for [AddToListDialog] parent component.
  const AddToListBody({
    super.key,
    required this.pageScrollController,
    this.pageState = EnumPageState.idle,
    this.onScroll,
    this.quoteLists = const [],
    this.maxHeight = 300,
    this.maxWidth = 300,
    this.onTapListItem,
    this.selectedQuoteLists = const [],
  });

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

  /// List of quote lists.
  final List<QuoteList> quoteLists;

  /// Selected quote lists to add quote(s) to.
  final List<QuoteList> selectedQuoteLists;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  "loading".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const LinearProgressIndicator(),
            ],
          ),
        ),
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
                    // return Text(quoteList.name);
                    return AddToListItem(
                      quoteList: quoteList,
                      onTap: onTapListItem,
                      selected: selectedQuoteLists.contains(quoteList),
                    );

                    // final Book book = _books.elementAt(index);

                    // return BookTile(
                    //   book: book,
                    //   onTapBook: onTapBook,
                    //   selected: _selectedBooks.contains(book),
                    // );
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
