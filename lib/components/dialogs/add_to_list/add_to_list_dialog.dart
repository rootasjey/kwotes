import "dart:async";
import "dart:math";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_body.dart";
import "package:kwotes/components/dialogs/add_to_list/create_list_dialog.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_footer.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_header.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_mobile.dart";
import "package:kwotes/components/dialogs/themed_dialog.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/quote_list.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

class AddToListDialog extends StatefulWidget {
  /// Dialog for adding one or more quotes to one or multiple lists.
  const AddToListDialog({
    super.key,
    required this.userId,
    this.asBottomSheet = false,
    this.autofocus = false,
    this.startInCreate = false,
    this.isIpad = false,
    this.selectedColor,
    this.quotes = const [],
    this.scrollController,
  });

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Will request focus on mount if true.
  final bool autofocus;

  /// Add bottom margin if true.
  final bool isIpad;

  /// If true, the widget will show inputs to create a new list.
  final bool startInCreate;

  /// Selected list color.
  final Color? selectedColor;

  /// List of quotes to add to a list.
  final List<Quote> quotes;

  /// Scroll controller for this widget.
  final ScrollController? scrollController;

  /// User's id.
  final String userId;

  @override
  State<AddToListDialog> createState() => _AddToListDialogState();
}

class _AddToListDialogState extends State<AddToListDialog> with UiLoggy {
  /// Fetch order.
  final bool _descending = true;

  /// If true, multiple lists can be selected.
  /// Otherwise, only one list can be selected,
  /// and the dialog will be closed after selection.
  bool _multiSelect = false;

  /// More books can be fetched if true.
  bool _hasNextPage = false;

  /// Page's state (e.g. idle, loading).
  EnumPageState _pageState = EnumPageState.idle;

  /// If true, the widget will show inputs to create a new book.
  /// Otherwise, a list of available books will be displayed.
  bool _createMode = false;

  /// Last fetched document (from Firestore).
  DocumentSnapshot? _lastDocument;

  /// Maximum books to fetch per page.
  final int _limit = 50;

  /// Scroll controller for this widget.
  ScrollController? _pageScrollController;

  /// Controller for new book name.
  final TextEditingController _nameController = TextEditingController();

  /// Controller for new book description.
  final TextEditingController _descriptionController = TextEditingController();

  /// Random hint number.
  int _randomHintNumber = 0;

  /// User's quote lists.
  final List<QuoteList> _quoteLists = [];

  /// Selected quote lists to add quote(s) to.
  final List<QuoteList> _selectedLists = [];

  /// Timer for name changed.
  Timer? _timerNameChanged;

  @override
  void initState() {
    super.initState();
    _pageScrollController = widget.scrollController ?? ScrollController();
    _randomHintNumber = Random().nextInt(9);
    _createMode = widget.startInCreate;
    fetch();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timerNameChanged?.cancel();
    _descriptionController.dispose();
    _lastDocument = null;

    if (widget.scrollController == null) {
      _pageScrollController?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_createMode) {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      return CreateListDialog(
        asBottomSheet: widget.asBottomSheet,
        nameController: _nameController,
        descriptionController: _descriptionController,
        quotes: widget.quotes,
        onNameListChanged: onNameListChanged,
        onCancel: Beamer.of(context).popRoute,
        onValidate: onCreateList,
        onTapBackButton: hideCreationInputs,
        pageScrollController: _pageScrollController ?? ScrollController(),
        randomHintNumber: _randomHintNumber,
        accentColor: widget.selectedColor,
        buttonBackgroundColor:
            isDark ? Colors.blue.shade900 : Colors.blue.shade100,
      );
    }

    if (widget.asBottomSheet) {
      return AddToListMobile(
        asBottomSheet: widget.asBottomSheet,
        isIpad: widget.isIpad,
        onScroll: onScroll,
        quoteLists: _quoteLists,
        selectedQuoteLists: _selectedLists,
        onValidate: onAddToLists,
        selectedColor: widget.selectedColor,
        pageState: _pageState,
        pageScrollController: _pageScrollController ?? ScrollController(),
        quotes: widget.quotes,
        onTapListItem: onTapListItem,
        onLongPressListItem: onLongPressListItem,
        showCreationInputs: showCreationInputs,
        onCancelMultiselect: onCancelMultiselect,
        showMultiSelectValidation: _multiSelect,
      );
    }

    return ThemedDialog(
      width: 400.0,
      height: 474.0,
      autofocus: widget.autofocus,
      useRawDialog: true,
      title: AddToListHeader(
        quoteLength: widget.quotes.length,
        onTapCreateList: showCreationInputs,
      ),
      body: AddToListBody(
        onScroll: onScroll,
        pageState: _pageState,
        selectedColor: widget.selectedColor,
        maxWidth: 360.0,
        pageScrollController: _pageScrollController ?? ScrollController(),
        quoteLists: _quoteLists,
        selectedQuoteLists: _selectedLists,
        onTapListItem: onTapListItem,
      ),
      footer: AddToListFooter(
        asBottomSheet: widget.asBottomSheet,
        selectedColor: widget.selectedColor,
        selectedLists: _selectedLists,
        onCancelMultiselect: onCancelMultiselect,
        onValidate: onAddToLists,
        pageState: _pageState,
        show: _multiSelect,
      ),
      onCancel: Beamer.of(context).popRoute,
      onValidate:
          _selectedLists.isEmpty ? null : () => onAddToLists(_selectedLists),
    );
  }

  /// Return firebase query.
  QueryMap getQuery(String userId) {
    final DocumentSnapshot<Object?>? lastDocument = _lastDocument;

    if (lastDocument == null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("lists")
          .orderBy("updated_at", descending: _descending)
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .collection("lists")
        .orderBy("updated_at", descending: _descending)
        .limit(_limit)
        .startAfterDocument(lastDocument);
  }

  void fetch() async {
    if (widget.userId.isEmpty) {
      return;
    }

    setState(() {
      _pageState = EnumPageState.loading;
    });

    try {
      final query = getQuery(widget.userId);
      final QuerySnapMap snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      for (var doc in snapshot.docs) {
        final map = doc.data();
        map["id"] = doc.id;
        _quoteLists.add(QuoteList.fromMap(map));
      }

      setState(() {
        _lastDocument = snapshot.docs.last;
        _hasNextPage = snapshot.size == _limit;
        _pageState = EnumPageState.idle;
      });
    } catch (error) {
      loggy.error(error);

      setState(() {
        _pageState = EnumPageState.error;
      });
    }
  }

  /// Hide creation inputs.
  void hideCreationInputs() {
    setState(() => _createMode = false);
  }

  /// Add selected quote to one or more lists.
  void onAddToLists(List<QuoteList> listQuoteArray) async {
    for (final QuoteList list in listQuoteArray) {
      for (final Quote quote in widget.quotes) {
        UserActions.addQuoteToList(
          userId: widget.userId,
          quote: quote,
          listId: list.id,
        ).then((bool success) {
          if (success) {
            return;
          }

          Utils.graphic.showSnackbar(
            context,
            message: "list.error.add.quote.named".tr(args: [list.name]),
          );
        });
      }
    }

    Navigator.of(context).pop();
  }

  /// Cancel multiselect.
  void onCancelMultiselect() {
    _multiSelect = false;
    setState(() => _selectedLists.clear());
  }

  /// Create a new list and add a quote to it.
  void onCreateList() async {
    if (_nameController.text.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "list.create.not_empty".tr(),
      );
      return;
    }

    Beamer.of(context).popRoute();

    final QuoteList? newList = await UserActions.createList(
      userId: widget.userId,
      name: _nameController.text,
      description: _descriptionController.text,
    );

    if (newList == null) {
      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: "list.error.create.named".tr(args: [
          _nameController.text,
        ]),
      );
      return;
    }

    onAddToLists([newList]);

    if (!mounted) return;
    Utils.graphic.showSnackbar(
      context,
      message: "list.create.success".tr(args: [
        _nameController.text,
      ]),
    );
  }

  /// Callback fired when a quote list is long pressed.
  /// Trigger multiselect.
  void onLongPressListItem(QuoteList quoteList) {
    if (_selectedLists.contains(quoteList)) {
      if (_selectedLists.isEmpty) {
        _multiSelect = false;
      }

      setState(() => _selectedLists.remove(quoteList));
      return;
    }

    _multiSelect = true;
    setState(() => _selectedLists.add(quoteList));
  }

  /// On name changed.
  /// Debounce for 500ms.
  void onNameListChanged(String name) {
    _timerNameChanged?.cancel();
    _timerNameChanged = Timer(const Duration(milliseconds: 75), () {
      setState(() {});
    });
  }

  /// Callback fired when the user scrolls.
  void onScroll(double offset) {
    if (!_hasNextPage) {
      return;
    }

    if (_pageState == EnumPageState.loading ||
        _pageState == EnumPageState.loadingMore) {
      return;
    }

    final double maxScrollExtent =
        _pageScrollController?.position.maxScrollExtent ?? 0.0;

    if (maxScrollExtent - offset <= 200) {
      fetch();
    }
  }

  /// Callback fired when a quote list is tapped.
  void onTapListItem(QuoteList quoteList) {
    if (!_multiSelect) {
      onAddToLists([quoteList]);
      return;
    }

    if (_selectedLists.contains(quoteList)) {
      setState(() => _selectedLists.remove(quoteList));
      return;
    }

    setState(() => _selectedLists.add(quoteList));
  }

  /// Show creation inputs.
  void showCreationInputs() {
    final UserFirestore userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value;

    if (userFirestore.plan == EnumUserPlan.free && _quoteLists.isNotEmpty) {
      Beamer.of(context, root: true).beamToNamed(
        HomeLocation.premiumRoute,
      );
      return;
    }

    setState(() => _createMode = true);
  }
}
