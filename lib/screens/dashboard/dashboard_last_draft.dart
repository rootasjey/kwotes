import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/buttons/underlined_button.dart";
import "package:kwotes/components/texts/quote_text.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_quote_text_magnitude.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_change_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/firestore/query_snapshot_stream_subscription.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

class DashboardLastDraft extends StatefulWidget {
  /// Displays the current user's last draft quote.
  const DashboardLastDraft({super.key});

  @override
  State<DashboardLastDraft> createState() => _DashboardLastDraftState();
}

class _DashboardLastDraftState extends State<DashboardLastDraft> with UiLoggy {
  /// Items fetch order.
  final bool _descending = true;

  /// Limit fetch query.
  final int _limit = 1;

  /// Draft quotes.
  final List<DraftQuote> _drafts = [];

  /// Stream subscription for draft quotes.
  QuerySnapshotStreamSubscription? _draftSub;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_drafts.isEmpty) {
      return const SizedBox.shrink();
    }

    final DraftQuote lastDraft = _drafts.last;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return Padding(
      padding: isMobileSize
          ? const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0)
          : const EdgeInsets.symmetric(vertical: 12.0, horizontal: 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UnderlinedButton(
            textValue: "drafts.last_single".tr(),
            accentColor: Constants.colors.drafts,
            onPressed: onTitlePressed,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: QuoteText(
              magnitude: EnumQuoteTextMagnitude.small,
              quote: lastDraft,
              onTap: (_) => onDraftPressed(),
              margin: const EdgeInsets.only(left: 4.0),
            ),
          ),
        ],
      ),
    );
  }

  void fetch() async {
    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final UserFirestore userFirestore = signalUserFirestore.value;
    if (userFirestore.id.isEmpty) {
      return;
    }

    try {
      final QueryMap query = getQuery(userFirestore.id);
      final QuerySnapMap snapshot = await query.get();
      listenToDraftChanges(query);

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        final DraftQuote quote = DraftQuote.fromMap(data);
        _drafts.add(quote);
      }

      setState(() {});
    } catch (error) {
      loggy.error(error);
    }
  }

  QueryMap getQuery(String userId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("drafts")
        .orderBy("created_at", descending: _descending)
        .limit(_limit);
  }

  /// Callback fired when a draft is added to the Firestore collection.
  void handleAddedDraft(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    final DraftQuote foundDraft = _drafts.firstWhere(
      (DraftQuote x) => x.id == doc.id,
      orElse: () => DraftQuote.empty(),
    );

    if (foundDraft.id.isNotEmpty) {
      return;
    }

    data["id"] = doc.id;
    final DraftQuote draft = DraftQuote.fromMap(data);
    _drafts.clear();
    _drafts.add(draft);

    if (!mounted) return;
    setState(() {});
  }

  /// Callback fired when a draft is modified in the Firestore collection.
  void handleModifiedDraft(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    final int index = _drafts.indexWhere(
      (DraftQuote x) => x.id == doc.id,
    );

    if (index == -1) {
      return;
    }

    data["id"] = doc.id;
    final DraftQuote draft = DraftQuote.fromMap(data);
    if (!mounted) return;
    setState(() => _drafts[index] = draft);
  }

  /// Callback fired when a draft is removed from the Firestore collection.
  void handleRemovedDraft(DocumentSnapshotMap doc) {
    final int index = _drafts.indexWhere(
      (DraftQuote x) => x.id == doc.id,
    );

    if (index == -1) {
      return;
    }

    if (!mounted) return;
    setState(() => _drafts.removeAt(index));
  }

  /// Listen to draft quotes changes.
  void listenToDraftChanges(QueryMap query) {
    _draftSub?.cancel();
    _draftSub = query.snapshots().skip(1).listen((QuerySnapMap snapshot) {
      for (final DocumentChangeMap docChange in snapshot.docChanges) {
        switch (docChange.type) {
          case DocumentChangeType.added:
            handleAddedDraft(docChange.doc);
            break;
          case DocumentChangeType.modified:
            handleModifiedDraft(docChange.doc);
            break;
          case DocumentChangeType.removed:
            handleRemovedDraft(docChange.doc);
            break;
          default:
            break;
        }
      }
    }, onDone: () {
      _draftSub?.cancel();
      _draftSub = null;
    });
  }

  /// Callback called when the last draft is pressed.
  void onDraftPressed() {
    if (_drafts.isEmpty) return;
    NavigationStateHelper.quote = _drafts.first;
    context.beamToNamed(
      DashboardContentLocation.editQuoteRoute.replaceFirst(
        ":quoteId",
        _drafts.first.id,
      ),
    );
  }

  /// Callback called when the title is pressed.
  /// Navigates to the drafts page.
  void onTitlePressed() {
    context.beamToNamed(DashboardContentLocation.draftsRoute);
  }
}
