import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_footer.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_header.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote_list.dart";

class AddToListMobile extends StatelessWidget {
  /// Mobile component for [AddToListDialog].
  const AddToListMobile({
    super.key,
    required this.pageScrollController,
    this.quoteLists = const [],
    this.selectedLists = const [],
    this.asBottomSheet = false,
    this.pageState = EnumPageState.idle,
    this.onScroll,
    this.onValidate,
    this.showCreationInputs,
  });

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// On scroll callback.
  final void Function(double)? onScroll;

  /// List of user's quote lists.
  final List<QuoteList> quoteLists;

  /// List of selected lists.
  final List<QuoteList> selectedLists;

  /// Trigger when the user tap on validation button
  final void Function(List<QuoteList> selectedLists)? onValidate;

  /// Callback fired to show creation inputs.
  final void Function()? showCreationInputs;

  /// Scroll controller.
  final ScrollController pageScrollController;

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

    return Stack(
      children: [
        ImprovedScrolling(
          onScroll: onScroll,
          scrollController: pageScrollController,
          child: CustomScrollView(
            controller: pageScrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const AddToListHeader(
                      margin: EdgeInsets.all(12.0),
                    ),
                    Divider(
                      thickness: 2.0,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final QuoteList quoteList = quoteLists.elementAt(index);
                      return Text(quoteList.name);

                      // return BookTile(
                      //   book: book,
                      //   onTapBook: onTapBook,
                      //   selected: _selectedLists.contains(book),
                      // );
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
            selectedLists: selectedLists,
            showCreationInputs: showCreationInputs,
            onValidate: selectedLists.isEmpty ? null : onValidate,
            pageState: pageState,
          ),
        ),
      ],
    );
  }
}
