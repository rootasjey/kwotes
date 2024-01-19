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
import "package:kwotes/types/enums/enum_quote_text_magnitude.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_change_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/firestore/query_snapshot_stream_subscription.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

class DashboardLastPublished extends StatefulWidget {
  /// Displays the current user's last published quote.
  const DashboardLastPublished({super.key});

  @override
  State<DashboardLastPublished> createState() => _DashboardLastPublishedState();
}

class _DashboardLastPublishedState extends State<DashboardLastPublished>
    with UiLoggy {
  /// Items fetch order.
  final bool _descending = true;

  /// Limit fetch query.
  final int _limit = 1;

  /// Published quotes.
  final List<Quote> _published = [];

  /// Stream subscription for published quotes.
  QuerySnapshotStreamSubscription? _publishedSub;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_published.isEmpty) {
      return const SizedBox.shrink();
    }

    final Quote lastPublished = _published.last;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return Padding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
          : const EdgeInsets.only(
              top: 12.0,
              left: 48.0,
              right: 48.0,
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UnderlinedButton(
            textValue: "published.last_single".tr(),
            accentColor: Constants.colors.published,
            onPressed: onTitlePressed,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: QuoteText(
              magnitude: EnumQuoteTextMagnitude.small,
              quote: lastPublished,
              onTap: (_) => onQuotePressed(),
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
      listenToQuoteChanges(query);

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        final Quote quote = Quote.fromMap(data);
        _published.add(quote);
      }

      setState(() {});
    } catch (error) {
      loggy.error(error);
    }
  }

  QueryMap getQuery(String userId) {
    return FirebaseFirestore.instance
        .collection("quotes")
        .where("user.id", isEqualTo: userId)
        .orderBy("created_at", descending: _descending)
        .limit(_limit);
  }

  /// Callback fired when a quote is added to the Firestore collection.
  void handleAddedQuote(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    final Quote foundQuote = _published.firstWhere(
      (Quote x) => x.id == doc.id,
      orElse: () => Quote.empty(),
    );

    if (foundQuote.id.isNotEmpty) {
      return;
    }

    data["id"] = doc.id;
    final Quote published = Quote.fromMap(data);
    setState(() {
      _published.clear();
      _published.add(published);
    });
  }

  /// Callback fired when a quote is modified in the Firestore collection.
  void handleModifiedQuote(DocumentSnapshotMap doc) {
    final Json? data = doc.data();
    if (data == null) {
      return;
    }

    final int index = _published.indexWhere(
      (Quote x) => x.id == doc.id,
    );

    if (index == -1) {
      return;
    }

    data["id"] = doc.id;
    final Quote published = Quote.fromMap(data);
    setState(() => _published[index] = published);
  }

  /// Callback fired when a quote is removed from the Firestore collection.
  void handleRemovedQuote(DocumentSnapshotMap doc) {
    final int index = _published.indexWhere(
      (Quote x) => x.id == doc.id,
    );

    if (index == -1) {
      return;
    }

    setState(() => _published.removeAt(index));
  }

  /// Listen to quotes changes.
  void listenToQuoteChanges(QueryMap query) {
    _publishedSub?.cancel();
    _publishedSub = query.snapshots().skip(1).listen((QuerySnapMap snapshot) {
      for (final DocumentChangeMap docChange in snapshot.docChanges) {
        switch (docChange.type) {
          case DocumentChangeType.added:
            handleAddedQuote(docChange.doc);
            break;
          case DocumentChangeType.modified:
            handleModifiedQuote(docChange.doc);
            break;
          case DocumentChangeType.removed:
            handleRemovedQuote(docChange.doc);
            break;
          default:
            break;
        }
      }
    }, onDone: () {
      _publishedSub?.cancel();
      _publishedSub = null;
    });
  }

  /// Callback called when the last published quote is pressed.
  void onQuotePressed() {
    if (_published.isEmpty) return;
    NavigationStateHelper.quote = _published.first;
    context.beamToNamed(
      DashboardContentLocation.publishedQuoteRoute.replaceFirst(
        ":quoteId",
        _published.first.id,
      ),
    );
  }

  /// Callback called when the title is pressed.
  /// Navigates to the published page.
  void onTitlePressed() {
    context.beamToNamed(DashboardContentLocation.publishedRoute);
  }
}
