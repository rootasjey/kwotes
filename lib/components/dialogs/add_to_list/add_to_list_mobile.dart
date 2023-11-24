import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_footer.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_header.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_item.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/quote_list.dart";

class AddToListMobile extends StatelessWidget {
  /// Mobile component for [AddToListDialog].
  const AddToListMobile({
    super.key,
    required this.pageScrollController,
    this.quoteLists = const [],
    this.selectedQuoteLists = const [],
    this.onTapListItem,
    this.asBottomSheet = false,
    this.pageState = EnumPageState.idle,
    this.selectedColor,
    this.quotes = const [],
    this.onScroll,
    this.onValidate,
    this.showCreationInputs,
  });

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Selected list color.
  final Color? selectedColor;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// On scroll callback.
  final void Function(double)? onScroll;

  /// List of quotes to add to a list.
  final List<Quote> quotes;

  /// List of user's quote lists.
  final List<QuoteList> quoteLists;

  /// Selected quote lists to add quote(s) to.
  final List<QuoteList> selectedQuoteLists;

  /// Trigger when the user tap on validation button
  final void Function(List<QuoteList> selectedLists)? onValidate;

  /// Callback fired to show creation inputs.
  final void Function()? showCreationInputs;

  /// Callback fired when a quote list is tapped.
  final void Function(QuoteList quoteList)? onTapListItem;

  /// Scroll controller.
  final ScrollController pageScrollController;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        useSliver: false,
        message: "loading".tr(),
      );
    }

    return Stack(
      children: [
        ImprovedScrolling(
          onScroll: onScroll,
          scrollController: pageScrollController,
          child: CustomScrollView(
            shrinkWrap: true,
            controller: pageScrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    AddToListHeader(
                      quoteLength: quotes.length,
                      margin: const EdgeInsets.all(12.0),
                    ),
                    const Divider(thickness: 2.0),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final QuoteList quoteList = quoteLists.elementAt(index);
                      return AddToListItem(
                        quoteList: quoteList,
                        onTap: onTapListItem,
                        selected: selectedQuoteLists.contains(quoteList),
                        selectedColor: selectedColor,
                      );
                    },
                    childCount: quoteLists.length,
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 150.0),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: AddToListFooter(
            asBottomSheet: asBottomSheet,
            elevation: 6.0,
            selectedColor: selectedColor,
            selectedLists: selectedQuoteLists,
            showCreationInputs: showCreationInputs,
            onValidate: selectedQuoteLists.isEmpty ? null : onValidate,
            pageState: pageState,
          ),
        ),
      ],
    );
  }
}
