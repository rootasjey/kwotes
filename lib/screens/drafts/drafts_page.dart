import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/drafts/drafts_page_body.dart";
import "package:kwotes/screens/drafts/drafts_page_header.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/user/user_auth.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

class DraftsPage extends StatefulWidget {
  const DraftsPage({super.key});

  @override
  State<DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> with UiLoggy {
  /// Animate list's items if true.
  bool _animateList = true;

  /// True if more results can be loaded.
  bool _hasNextPage = true;

  /// True if the order is the most recent first.
  final bool _descending = true;

  /// Show page options (e.g. language) if true.
  bool _showPageOptions = true;

  /// Color of selected widgets (e.g. for filter chips).
  Color _selectedColor = Colors.amber.shade200;

  /// Current selected language to fetch draft quotes.
  EnumLanguageSelection _selectedLanguage = EnumLanguageSelection.all;

  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// Result count limit.
  final int _limit = 20;

  /// List of drafts quotes.
  final List<DraftQuote> _quotes = [];

  /// Last document.
  QueryDocSnapMap? _lastDocument;

  /// Page's scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return Scaffold(
      body: ImprovedScrolling(
        scrollController: _pageScrollController,
        onScroll: onScroll,
        child: ScrollConfiguration(
          behavior: const CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: [
              PageAppBar(
                isMobileSize: isMobileSize,
                childTitle: DraftsPageHeader(
                  isMobileSize: isMobileSize,
                  onSelectLanguage: onSelectedLanguage,
                  onTapTitle: onTapTitle,
                  selectedColor: _selectedColor,
                  selectedLanguage: _selectedLanguage,
                  show: _showPageOptions,
                ),
              ),
              DraftsPageBody(
                animateList: _animateList,
                isMobileSize: isMobileSize,
                pageState: _pageState,
                draftQuotes: _quotes,
                onTap: onTapDraftQuote,
                onDelete: onDeleteDraftQuote,
                onEdit: onEditDraftQuote,
                onCopyFrom: onCopyFromDraftQuote,
              ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 96.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetch() async {
    final UserAuth? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final String userId = currentUser.uid;

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
        final DraftQuote quote = DraftQuote.fromMap(data);
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

  QueryMap getQuery(String userId) {
    final QueryDocSnapMap? lastDocument = _lastDocument;

    QueryMap baseQuery = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("drafts")
        .orderBy("created_at", descending: _descending)
        .limit(_limit);

    if (_selectedLanguage != EnumLanguageSelection.all) {
      baseQuery = baseQuery.where(
        "language",
        isEqualTo: _selectedLanguage.name,
      );
    }

    if (lastDocument == null) {
      return baseQuery;
    }

    return baseQuery.startAfterDocument(lastDocument);
  }

  /// Initialize page properties.
  void initProps() async {
    _showPageOptions = await Utils.vault.geShowtHeaderOptions();
    _selectedColor = Constants.colors.getRandomFromPalette().withOpacity(0.6);

    setState(() {});

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _animateList = false;
      });
    });
  }

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

  /// Callback fired when the draft quote is tapped.
  /// Navigate to the edit page with the selected quote.
  void onTapDraftQuote(DraftQuote draftQuote) {
    onEditDraftQuote(draftQuote);
  }

  /// Callback fired when a draft quote is going to be deleted.
  void onDeleteDraftQuote(DraftQuote quote) async {
    final int index = _quotes.indexOf(quote);
    setState(() {
      _quotes.removeAt(index);
    });

    final Signal<UserFirestore> userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userFirestore.value.id)
          .collection("drafts")
          .doc(quote.id)
          .delete();
    } catch (error) {
      loggy.error(error);

      if (!mounted) return;

      setState(() {
        _quotes.insert(index, quote);
      });

      Utils.graphic.showSnackbar(
        context,
        message: "quote.delete.failed".tr(),
      );
    }
  }

  /// Callback fired when a draft quote is going to be edited.
  void onEditDraftQuote(DraftQuote draftQuote) {
    NavigationStateHelper.quote = draftQuote;
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }

  /// Create a new quote from an existing draft.
  void onCopyFromDraftQuote(DraftQuote quote) {
    NavigationStateHelper.quote = quote.copyDraftWith(id: "");
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }

  /// Callback to select a language.
  void onSelectedLanguage(EnumLanguageSelection language) {
    if (_selectedLanguage == language) {
      return;
    }

    setState(() {
      _selectedLanguage = language;
      _quotes.clear();
      _lastDocument = null;
    });

    Utils.vault.setPageLanguage(language);
    fetch();
  }

  /// Callback to show/hide page options.
  void onTapTitle() {
    final bool newShowPageOptions = !_showPageOptions;
    Utils.vault.setShowHeaderOptions(newShowPageOptions);
    setState(() => _showPageOptions = newShowPageOptions);
  }
}
