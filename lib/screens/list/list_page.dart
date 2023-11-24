import "dart:math";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/list/list_page_body.dart";
import "package:kwotes/screens/list/list_page_header.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/intents/escape_intent.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/quote_list.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

class ListPage extends StatefulWidget {
  const ListPage({
    super.key,
    required this.listId,
  });

  /// Quote list's id.
  final String listId;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with UiLoggy {
  /// Animate list's items if true.
  bool _animateList = true;

  /// Page's state.
  EnumPageState _pageState = EnumPageState.loading;

  /// Show text inputs (to edit list's name & description) if this true.
  bool _createMode = false;

  /// Will focus name input on show if true.
  bool _focusNameInput = true;

  /// True if more results can be loaded.
  bool _hasNextPage = true;

  /// Page accent color.
  Color _accentColor = Colors.amber;

  /// True if the order is the most recent first.
  // final bool _descending = true;

  /// Last document.
  QueryDocSnapMap? _lastDocument;

  /// List of quotes in a user list.
  final List<Quote> _quotes = [];

  /// Quote list metadata.
  QuoteList _quoteList = QuoteList.empty();

  /// Result count limit.
  final int _limit = 20;

  final Map<SingleActivator, EscapeIntent> _shortcuts = {
    const SingleActivator(LogicalKeyboardKey.escape): const EscapeIntent(),
  };

  /// Page scroll controller.
  final ScrollController _scrollController = ScrollController();

  /// Previous string value from name input.
  String _prevName = "";

  /// Random description hint text.
  String _descriptionHintText = "";

  /// Text controller to edit list's name.
  final TextEditingController _nameController = TextEditingController();

  /// Text controller to edit list's description.
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initProps();
    _accentColor = Constants.colors.getRandomFromPalette();
    _descriptionHintText =
        "list.create.hints.descriptions.${Random().nextInt(9)}".tr();
    fetch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final void Function()? onSave =
        _nameController.text.isEmpty ? null : trySaveList;

    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: {
          if (_createMode)
            EscapeIntent: CallbackAction<EscapeIntent>(
              onInvoke: onEscapeShortcut,
            ),
        },
        child: Scaffold(
          body: ImprovedScrolling(
            scrollController: _scrollController,
            onScroll: onScroll,
            child: ScrollConfiguration(
              behavior: const CustomScrollBehavior(),
              child: CustomScrollView(
                slivers: [
                  PageAppBar(
                    isMobileSize: isMobileSize,
                    toolbarHeight: 240.0,
                    children: [
                      ListPageHeader(
                        accentColor: _accentColor,
                        createMode: _createMode,
                        isMobileSize: isMobileSize,
                        description: _quoteList.description,
                        descriptionHintText: _descriptionHintText,
                        descriptionController: _descriptionController,
                        focusName: _focusNameInput,
                        listId: widget.listId,
                        nameController: _nameController,
                        onEnterCreateMode: onEnterCreateMode,
                        onNameChanged: onNameChanged,
                        onSave: onSave,
                        onCancelCreateMode: onCancelCreateMode,
                        title: _quoteList.name,
                      ),
                    ],
                  ),
                  ListPageBody(
                    animateList: _animateList,
                    isMobileSize: isMobileSize,
                    pageState: _pageState,
                    quotes: _quotes,
                    onCopy: onCopy,
                    onTap: onTap,
                    onRemove: onRemoveFromList,
                    userId: currentUser.value.id,
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

  /// Fetch data.
  void fetch() async {
    await fetchListMetadata();
    await fetchQuotes();
  }

  /// Fetch list metadata (name, description, public).
  Future fetchListMetadata() async {
    if (NavigationStateHelper.quoteList.id == widget.listId) {
      setState(() {
        _quoteList = NavigationStateHelper.quoteList;
      });
      return;
    }

    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);
    if (currentUser.value.id.isEmpty) {
      return;
    }

    final String userId = currentUser.value.id;

    try {
      final docListSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("lists")
          .doc(widget.listId)
          .get();

      if (!docListSnap.exists) {
        if (!mounted) {
          return;
        }
        context.beamBack();
        return;
      }

      final Json? map = docListSnap.data();
      map?["id"] = docListSnap.id;

      setState(() {
        _pageState = EnumPageState.idle;
        _quoteList = QuoteList.fromMap(map);
      });
    } catch (error) {
      loggy.error(error);
    }
  }

  /// Fetch quotes.
  Future fetchQuotes() async {
    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (currentUser.value.id.isEmpty) {
      return;
    }

    final String userId = currentUser.value.id;

    try {
      final QueryMap query = getQuery(userId);
      final QuerySnapMap snapshot = await query.get();

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
        final Quote quote = Quote.fromMap(data);
        _quotes.add(quote);
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _lastDocument = snapshot.docs.last;
        _hasNextPage = _limit == snapshot.docs.length;
      });
    } catch (error) {
      loggy.error(error);
      setState(() {
        _pageState = EnumPageState.idle;
      });
    }
  }

  /// Return firestore query according to the last fetched document.
  QueryMap getQuery(String userId) {
    final QueryDocSnapMap? lastDocument = _lastDocument;

    if (lastDocument == null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("lists")
          .doc(widget.listId)
          .collection("quotes")
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("lists")
        .doc(widget.listId)
        .collection("quotes")
        .limit(_limit)
        .startAfterDocument(lastDocument);
  }

  void initProps() async {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _animateList = false;
      });
    });
  }

  /// Exit create mode and hide text inputs.
  void onCancelCreateMode() {
    setState(() {
      _createMode = false;
      _nameController.text = "";
      _descriptionController.text = "";
    });
  }

  /// Copy a quote's name.
  void onCopy(Quote quote) {
    QuoteActions.copyQuote(quote);
  }

  /// Callback to enter create mode.
  void onEnterCreateMode(bool focusNameInput) {
    setState(() {
      _createMode = true;
      _accentColor = Constants.colors.getRandomFromPalette();

      _prevName = _quoteList.name;
      _nameController.text = _quoteList.name;
      _descriptionController.text = _quoteList.description;
      _focusNameInput = focusNameInput;
    });
  }

  /// Escape shortcut.
  /// Close create panel component.
  Object? onEscapeShortcut(EscapeIntent intent) {
    onCancelCreateMode();
    return null;
  }

  /// Callback when list's name has changed.
  void onNameChanged(String name) {
    if (_prevName.isNotEmpty && name.isEmpty) {
      setState(() {
        _prevName = name;
      });
      return;
    }

    if (_prevName.isEmpty && name.isNotEmpty) {
      setState(() {
        _prevName = name;
      });
      return;
    }

    _prevName = name;
  }

  /// Remove a quote from a list.
  void onRemoveFromList(Quote quote) async {
    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (currentUser.value.id.isEmpty) {
      return;
    }

    final String userId = currentUser.value.id;

    final int index = _quotes.indexWhere((x) => x.id == quote.id);
    if (index == -1) {
      return;
    }

    setState(() {
      _quotes.removeAt(index);
    });

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("lists")
          .doc(widget.listId)
          .collection("quotes")
          .doc(quote.id)
          .delete();
    } catch (error) {
      loggy.error(error);

      setState(() {
        _quotes.insert(index, quote);
      });
    }
  }

  /// Callback called when user scrolls the list.
  void onScroll(double offset) {
    if (!_hasNextPage) {
      return;
    }

    if (_pageState == EnumPageState.searching ||
        _pageState == EnumPageState.searchingMore) {
      return;
    }

    if (_scrollController.position.maxScrollExtent - offset <= 200) {
      fetchQuotes();
    }
  }

  /// Callback called when user taps a quote.
  void onTap(Quote quote) {
    NavigationStateHelper.quote = quote;
    context.beamToNamed("quotes/${quote.id}");
  }

  /// Save list's changes (name and description).
  void trySaveList() async {
    if (_nameController.text.isEmpty) {
      return;
    }

    final String prevName = _quoteList.name;
    final String prevDescription = _quoteList.description;

    setState(() {
      _createMode = false;
      _quoteList = _quoteList.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
      );
    });

    try {
      final String userId = context
          .get<Signal<UserFirestore>>(EnumSignalId.userFirestore)
          .value
          .id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("lists")
          .doc(widget.listId)
          .update(_quoteList.toMapUpdate());
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;

      setState(() {
        _quoteList = _quoteList.copyWith(
          name: prevName,
          description: prevDescription,
        );
      });

      Utils.graphic.showSnackbar(
        context,
        message: "list.error.update.name".tr(),
      );
    }
  }
}
