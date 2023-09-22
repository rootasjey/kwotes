import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/in_validation/in_validation_page_body.dart";
import "package:kwotes/screens/in_validation/in_validation_page_header.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_draft_quote_operation.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_auth.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/user/user_rights.dart";
import "package:loggy/loggy.dart";

class InValidationPage extends StatefulWidget {
  const InValidationPage({super.key});

  @override
  State<InValidationPage> createState() => _InValidationPageState();
}

class _InValidationPageState extends State<InValidationPage> with UiLoggy {
  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// True if more results can be loaded.
  bool _hasNextPage = true;

  /// True if the order is the most recent first.
  final bool _descending = true;

  /// Last document.
  QueryDocSnapMap? _lastDocument;

  /// List of draft quotes in validation.
  final List<DraftQuote> _quotes = [];

  /// Result count limit.
  final int _limit = 20;

  /// Page's scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  final String _collectionName = "drafts";

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImprovedScrolling(
        scrollController: _pageScrollController,
        onScroll: onScroll,
        child: ScrollConfiguration(
          behavior: const CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: [
              const ApplicationBar(),
              const InValidationPageHeader(),
              InValidationPageBody(
                pageState: _pageState,
                quotes: _quotes,
                onTap: onTapDraftQuote,
                onDelete: onDeleteDraftQuote,
                onValidate: onValidateDraftQuote,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns firestore query according to the last fetched document.
  QueryMap getQuery(String userId) {
    final QueryDocSnapMap? lastDocument = _lastDocument;

    if (lastDocument == null) {
      return FirebaseFirestore.instance
          .collection(_collectionName)
          .where("user.id", isEqualTo: userId)
          .orderBy("created_at", descending: _descending)
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection(_collectionName)
        .where("user.id", isEqualTo: userId)
        .orderBy("created_at", descending: _descending)
        .limit(_limit)
        // .where("language", isEqualTo: lang)
        .startAfterDocument(lastDocument);
  }

  /// Fetch draft quotes.
  void fetch() async {
    final UserAuth? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final String userId = currentUser.uid;
    _pageState = EnumPageState.loadingMore;

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
        data["in_validation"] = true;
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
        _pageState = EnumPageState.error;
      });
    }
  }

  /// Callback fired when the page is scrolled.
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

  /// Callback fired when a draft quote is tapped.
  void onTapDraftQuote(Quote draftQuote) {
    NavigationStateHelper.quote = draftQuote;
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }

  /// Callback fired when a draft quote in validation is deleted.
  void onDeleteDraftQuote(DraftQuote quote) async {
    final int index = _quotes.indexOf(quote);

    setState(() {
      _quotes.remove(quote);
    });

    try {
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(quote.id)
          .delete();
    } catch (error) {
      loggy.error(error);

      setState(() {
        _quotes.insert(index, quote);
      });

      Utils.graphic.showSnackbar(
        context,
        message: "quote.delete.failed".tr(),
      );
    }
  }

  /// Callback fired when a draft quote is validated.
  void onValidateDraftQuote(DraftQuote draft) async {
    final int index = _quotes.indexOf(draft);
    if (index == -1) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.not_found".tr(),
      );
      return;
    }

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestoreSignal.value.id.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.user.unauthenticated".tr(),
      );
      return;
    }

    final UserRights rights = userFirestoreSignal.value.rights;
    if (!rights.canManageQuotes) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.user.not_admin".tr(),
      );
      return;
    }

    setState(() {
      _quotes.removeAt(index);
    });

    try {
      await FirebaseFirestore.instance.collection("quotes").add(
            draft.toMap(
              userId: userFirestoreSignal.value.id,
              operation: EnumQuoteOperation.validate,
            ),
          );

      // Delete draft.
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(draft.id)
          .delete();
    } catch (error) {
      loggy.error(error);
      Utils.graphic.showSnackbar(
        context,
        message: "quote.validate.failed".tr(),
      );

      setState(() {
        _quotes.insert(index, draft);
      });
    }
  }
}
