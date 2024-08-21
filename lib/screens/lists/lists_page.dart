import "dart:math";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/lists/lists_page_body.dart";
import "package:kwotes/screens/lists/lists_page_create.dart";
import "package:kwotes/screens/lists/lists_page_header.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_change_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/firestore/query_snapshot_stream_subscription.dart";
import "package:kwotes/types/intents/escape_intent.dart";
import "package:kwotes/types/quote_list.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";
import "package:wave_divider/wave_divider.dart";

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> with UiLoggy {
  /// Animate list's items if true.
  bool _animateList = true;

  /// True if the order is the most recent first.
  final bool _descending = true;

  /// Show create component if true.
  bool _showCreate = false;

  /// True if more results can be loaded.
  bool _hasNextPage = true;

  /// Page accent color.
  final Color _accentColor = Constants.colors.lists;

  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// Last document.
  QueryDocSnapMap? _lastDocument;

  /// Array of lists of quotes 😅.
  final List<QuoteList> _lists = [];

  /// Result count limit.
  final int _limit = 20;

  /// New quote list if any.
  QuoteList _newQuoteList = QuoteList.empty();

  /// Page scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  /// Stream subscription for lists.
  QuerySnapshotStreamSubscription? _listSub;

  /// Hint text for list name.
  String _hintListName = "";

  /// Hint text for list description.
  String _hintListDescription = "";

  /// Id of the list which is being edited.
  /// Empty if no list is being edited.
  String _editingListId = "";

  /// Id of the list which is being deleted.
  /// Empty if no list is being deleted.
  String _deletingListId = "";

  final Map<SingleActivator, EscapeIntent> _shortcuts = {
    const SingleActivator(LogicalKeyboardKey.escape): const EscapeIntent(),
  };

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();

    final int hintIndex = Random().nextInt(9);
    _hintListName = "list.create.hints.names.$hintIndex".tr();
    _hintListDescription = "list.create.hints.descriptions.$hintIndex".tr();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _listSub?.cancel();
    _listSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCreateButtonActive =
        _pageState != EnumPageState.creatingList &&
            _pageState != EnumPageState.loading;

    final bool onCancelActive = _pageState != EnumPageState.creatingList;
    final bool onCreateActive = _pageState != EnumPageState.creatingList &&
        _newQuoteList.name.isNotEmpty;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final bool allowEscapeIntent =
        _showCreate || _editingListId.isNotEmpty || _deletingListId.isNotEmpty;

    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: {
          if (allowEscapeIntent)
            EscapeIntent: CallbackAction<EscapeIntent>(
              onInvoke: onEscapeShortcut,
            ),
        },
        child: Scaffold(
          body: ImprovedScrolling(
            scrollController: _pageScrollController,
            onScroll: onScroll,
            child: ScrollConfiguration(
              behavior: const CustomScrollBehavior(),
              child: CustomScrollView(
                slivers: [
                  PageAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    isMobileSize: isMobileSize,
                    toolbarHeight: isMobileSize ? 190.0 : 320.0,
                    children: [
                      ListsPageHeader(
                        accentColor: _accentColor,
                        isMobileSize: isMobileSize,
                        onTapNewListButton:
                            isCreateButtonActive ? onToggleCreate : null,
                        showCreate: _showCreate,
                      ),
                    ],
                  ),
                  ListsPageCreate(
                    show: _showCreate,
                    isMobileSize: isMobileSize,
                    accentColor: _accentColor,
                    hintName: _hintListName,
                    hintDescription: _hintListDescription,
                    onCancel: onCancelActive ? onCancelCreate : null,
                    onCreate: onCreateActive ? tryCreateList : null,
                    onDescriptionChanged: onListDescriptionChanged,
                    onNameChanged: onListNameChanged,
                  ),
                  SliverToBoxAdapter(
                    child: const WaveDivider(
                      padding: EdgeInsets.only(
                        bottom: 32.0,
                        top: 12.0,
                      ),
                    ).animate().fadeIn(
                          duration: const Duration(milliseconds: 1500),
                          begin: 0.0,
                        ),
                  ),
                  ListsPageBody(
                    animateList: _animateList,
                    isDark: isDark,
                    isMobileSize: isMobileSize,
                    editingListId: _editingListId,
                    deletingListId: _deletingListId,
                    lists: _lists,
                    pageState: _pageState,
                    onDeleteList: onTryDeleteList,
                    onCancelEditListMode: onCancelEditListMode,
                    onConfirmDeleteList: onConfirmDeleteList,
                    onCancelDeleteList: onCancelDeleteList,
                    onSaveListChanges: onTrySaveListChanges,
                    onOpenDeleteListValidation: onOpenDeleteConfirm,
                    onEditList: onTryEditList,
                    onTap: onTapQuoteList,
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 96.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fetch lists.
  void fetch() async {
    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (currentUser.value.id.isEmpty) {
      return;
    }

    final String userId = currentUser.value.id;

    setState(() {
      _pageState = EnumPageState.loading;
    });

    try {
      final QueryMap query = getQuery(userId);
      final QuerySnapMap snapshot = await query.get();
      listenToListChanges(query);

      if (snapshot.docs.isEmpty) {
        setState(() {
          _pageState = EnumPageState.idle;
          _hasNextPage = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        final QuoteList list = QuoteList.fromMap(data);
        _lists.add(list);
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _lastDocument = snapshot.docs.last;
        _hasNextPage = _limit == snapshot.docs.length;
      });
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() {
        _pageState = EnumPageState.idle;
      });
    }
  }

  QueryMap getQuery(String userId) {
    final QueryDocSnapMap? lastDocument = _lastDocument;

    if (lastDocument == null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("lists")
          .orderBy("updated_at", descending: _descending)
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("lists")
        .orderBy("updated_at", descending: _descending)
        .limit(_limit)
        .startAfterDocument(lastDocument);
  }

  /// Callback fired when a list is added to the collection.
  void handleAddedList(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    data["id"] = doc.id;
    final QuoteList createdList = QuoteList.fromMap(data);

    // Check if the list already exists.
    final int index = _lists.indexWhere(
      (QuoteList x) => (x.name == createdList.name) && x.id.isEmpty,
    );

    if (index > -1) {
      setState(() => _lists[index] = createdList);
      return;
    }

    setState(() => _lists.add(createdList));
  }

  /// Callback fired when a list is modifed in the collection.
  void handleModifiedList(DocumentSnapshotMap doc) {
    final int index = _lists.indexWhere((QuoteList list) => list.id == doc.id);

    if (index == -1) {
      return;
    }

    // final QuoteList existingList = _lists[index];
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    data["id"] = doc.id;
    final QuoteList newList = QuoteList.fromMap(data);
    setState(() => _lists[index] = newList);
  }

  /// Callback fired when a list is removed from the collection.
  void handleRemovedList(DocumentSnapshotMap doc) {
    final int index = _lists.indexWhere((QuoteList list) => list.id == doc.id);

    if (index == -1) {
      return;
    }

    setState(() {
      _lists.removeAt(index);
    });
  }

  /// Initialize properties.
  void initProps() async {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _animateList = false);
    });
  }

  /// Listen to list changes.
  void listenToListChanges(QueryMap query) {
    _listSub?.cancel();
    _listSub = query.snapshots().skip(1).listen((QuerySnapMap snapshot) {
      for (final DocumentChangeMap docChange in snapshot.docChanges) {
        switch (docChange.type) {
          case DocumentChangeType.added:
            handleAddedList(docChange.doc);
            break;
          case DocumentChangeType.modified:
            handleModifiedList(docChange.doc);
            break;
          case DocumentChangeType.removed:
            handleRemovedList(docChange.doc);
            break;
          default:
            break;
        }
      }
    }, onDone: () {
      _listSub?.cancel();
      _listSub = null;
    });
  }

  /// Fetch more data on scroll.
  void onScroll(double offset) {
    if (!_hasNextPage) {
      return;
    }

    if (_pageState == EnumPageState.searching ||
        _pageState == EnumPageState.searchingMore) {
      return;
    }

    if (_pageScrollController.position.maxScrollExtent - offset <= 200) {
      fetch();
    }
  }

  /// Handle tap on quote list.
  /// Navigate to the list's page.
  void onTapQuoteList(QuoteList quoteList) {
    NavigationStateHelper.quoteList = quoteList;

    context.beamToNamed(
      DashboardContentLocation.listRoute.replaceFirst(":listId", quoteList.id),
      routeState: {"listName": quoteList.name},
    );
  }

  /// Hide create panel component.
  void onCancelCreate() {
    setState(() {
      _showCreate = false;
      _newQuoteList = QuoteList.empty();
    });
  }

  /// Escape shortcut.
  /// Close create panel component.
  Object? onEscapeShortcut(EscapeIntent intent) {
    onCancelCreate();
    onCancelEditListMode();
    onCancelDeleteList(QuoteList.empty());
    return null;
  }

  /// Update list name.
  void onListNameChanged(String name) {
    setState(() {
      _newQuoteList = _newQuoteList.copyWith(name: name);
    });
  }

  /// Update list description.
  void onListDescriptionChanged(String description) {
    setState(() {
      _newQuoteList = _newQuoteList.copyWith(description: description);
    });
  }

  /// Show or hide create panel component depending on the current state.
  void onToggleCreate() {
    setState(() {
      final bool newShowCreate = !_showCreate;

      if (newShowCreate) {
        final int hintIndex = Random().nextInt(9);
        _hintListName = "list.create.hints.names.$hintIndex".tr();
        _hintListDescription = "list.create.hints.descriptions.$hintIndex".tr();
      } else {
        _newQuoteList = QuoteList.empty();
      }

      _showCreate = newShowCreate;
    });
  }

  /// Create new list.
  void tryCreateList() async {
    if (_newQuoteList.name.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "list.error.name.empty".tr(),
      );
      return;
    }

    final Signal<UserFirestore> userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestore.value.id.isEmpty) {
      return;
    }

    setState(() {
      _pageState = EnumPageState.creatingList;
      _lists.add(_newQuoteList.copyWith());
    });

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userFirestore.value.id)
          .collection("lists")
          .add(_newQuoteList.toMapUpdate());

      onCancelCreate();
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: "list.create.failed".tr(),
      );
    } finally {
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Delete list.
  void onTryDeleteList(QuoteList quoteList) async {
    final Signal<UserFirestore> userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestore.value.id.isEmpty) {
      return;
    }

    final int index = _lists.indexOf(quoteList);
    setState(() => _lists.remove(quoteList));

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userFirestore.value.id)
          .collection("lists")
          .doc(quoteList.id)
          .delete();
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;

      setState(() {
        _lists.insert(index, quoteList);
      });

      Utils.graphic.showSnackbar(
        context,
        message: "list.delete.failed".tr(),
      );
    }
  }

  /// Cancel edit list mode.
  void onCancelEditListMode() {
    setState(() => _editingListId = "");
  }

  /// Save list changes.
  void onTrySaveListChanges(String name, String description) async {
    if (name.isEmpty) {
      return;
    }

    final int index =
        _lists.indexWhere((QuoteList x) => x.id == _editingListId);

    if (index == -1) {
      return;
    }

    final QuoteList listToUpdate = _lists[index];
    final String prevName = listToUpdate.name;

    setState(() {
      _editingListId = "";
      _lists[index] = listToUpdate.copyWith(
        name: name,
      );
    });

    final String userId =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value.id;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("lists")
          .doc(listToUpdate.id)
          .update({
        "name": name,
        // "description": description,
      });
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;

      setState(() {
        _lists[index] = listToUpdate.copyWith(
          name: prevName,
          // description: prevDescription,
        );
      });

      Utils.graphic.showSnackbar(
        context,
        message: "list.error.update.name".tr(),
      );
    }
  }

  void onTryEditList(QuoteList quoteList) {
    setState(() => _editingListId = quoteList.id);
  }

  void onOpenDeleteConfirm(QuoteList quoteList) {
    setState(() {
      _deletingListId = quoteList.id;
    });
  }

  void onCancelDeleteList(QuoteList quoteList) {
    setState(() {
      _deletingListId = "";
    });
  }

  void onConfirmDeleteList(QuoteList quoteList) {
    setState(() {
      _deletingListId = "";
    });

    onTryDeleteList(quoteList);
  }
}
