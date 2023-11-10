import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_body.dart";
import "package:kwotes/components/dialogs/add_to_list/create_list_dialog.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_footer.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_header.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_mobile.dart";
import "package:kwotes/components/dialogs/themed_dialog.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/quote_list.dart";
import "package:loggy/loggy.dart";

class AddToListDialog extends StatefulWidget {
  /// Dialog for adding one or more quotes to one or multiple lists.
  const AddToListDialog({
    super.key,
    required this.userId,
    this.asBottomSheet = false,
    this.autoFocus = false,
    this.startInCreate = false,
    this.quotes = const [],
  });

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Will request focus on mount if true.
  final bool autoFocus;

  /// If true, the widget will show inputs to create a new list.
  final bool startInCreate;

  /// List of quotes to add to a list.
  final List<Quote> quotes;

  /// User's id.
  final String userId;

  @override
  State<AddToListDialog> createState() => _AddToListDialogState();
}

class _AddToListDialogState extends State<AddToListDialog> with UiLoggy {
  /// Fetch order.
  final bool _descending = true;

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
  final ScrollController _pageScrollController = ScrollController();

  /// Controller for new book name.
  final TextEditingController _nameController = TextEditingController();

  /// Controller for new book description.
  final TextEditingController _descriptionController = TextEditingController();

  /// User's quote lists.
  final List<QuoteList> _quoteLists = [];

  /// Selected quote lists to add quote(s) to.
  final List<QuoteList> _selectedLists = [];

  @override
  void initState() {
    super.initState();
    _createMode = widget.startInCreate;
    fetch();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _lastDocument = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_createMode) {
      return CreateListDialog(
        asBottomSheet: widget.asBottomSheet,
        nameController: _nameController,
        descriptionController: _descriptionController,
        quotes: widget.quotes,
        onCancel: Beamer.of(context).popRoute,
        onValidate: onCreateList,
      );
    }

    if (widget.asBottomSheet) {
      return AddToListMobile(
        asBottomSheet: widget.asBottomSheet,
        onScroll: onScroll,
        quoteLists: _quoteLists,
        selectedQuoteLists: _selectedLists,
        onValidate: onAddToLists,
        pageState: _pageState,
        pageScrollController: _pageScrollController,
        quotes: widget.quotes,
        onTapListItem: onTapListItem,
        showCreationInputs: showCreationInputs,
      );
    }

    return ThemedDialog(
      width: 400.0,
      autofocus: widget.autoFocus,
      useRawDialog: true,
      title: AddToListHeader(
        quoteLength: widget.quotes.length,
      ),
      body: AddToListBody(
        onScroll: onScroll,
        pageState: _pageState,
        maxWidth: 360.0,
        pageScrollController: _pageScrollController,
        quoteLists: _quoteLists,
        selectedQuoteLists: _selectedLists,
        onTapListItem: onTapListItem,
      ),
      footer: AddToListFooter(
        asBottomSheet: widget.asBottomSheet,
        selectedLists: _selectedLists,
        showCreationInputs: showCreationInputs,
        onValidate: onAddToLists,
        pageState: _pageState,
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
      // final QuerySnapMap snapshot = await FirebaseFirestore.instance
      //     .collection("users")
      //     .doc(widget.userId)
      //     .collection("lists")
      //     .limit(_limit)
      //     .get();

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

  /// Callback fired when the user scrolls.
  void onScroll(double offset) {
    if (!_hasNextPage) {
      return;
    }

    if (_pageState == EnumPageState.loading ||
        _pageState == EnumPageState.loadingMore) {
      return;
    }

    if (_pageScrollController.position.maxScrollExtent - offset <= 200) {
      fetch();
    }
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
  }

  /// Create a new list and add a quote to it.
  void onCreateList() async {
    Beamer.of(context).popRoute();

    final QuoteList? newList = await UserActions.createList(
      userId: widget.userId,
      name: _nameController.text,
      description: _descriptionController.text,
    );

    if (newList == null) {
      if (!mounted) {
        return;
      }

      Utils.graphic.showSnackbar(
        context,
        message: "list.error.create.named".tr(args: [
          _nameController.text,
        ]),
      );
      return;
    }

    onAddToLists([newList]);
  }

  void showCreationInputs() {
    setState(() {
      _createMode = true;
    });
  }

  void onTapListItem(QuoteList quoteList) {
    if (_selectedLists.contains(quoteList)) {
      setState(() {
        _selectedLists.remove(quoteList);
      });
      return;
    }

    setState(() {
      _selectedLists.add(quoteList);
    });
  }
}
