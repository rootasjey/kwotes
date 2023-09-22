import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/search_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/reference/reference_app_bar_children.dart";
import "package:kwotes/screens/reference/reference_page_body.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/doc_snapshot_stream_subscription.dart";
import "package:kwotes/types/firestore/document_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

class ReferencePage extends StatefulWidget {
  const ReferencePage({
    super.key,
    required this.referenceId,
  });

  /// Unique id of the reference.
  final String referenceId;

  @override
  State<ReferencePage> createState() => _ReferencePageState();
}

class _ReferencePageState extends State<ReferencePage> with UiLoggy {
  /// Firestore quote document reference.
  DocumentReference? _docRef;

  /// Subscription to author data.
  DocSnapshotStreamSubscription? _referenceSubscription;

  /// List of quotes associated with the author.
  final List<Quote> _referenceQuotes = [];

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Tooltip controller.
  final JustTheController _tooltipController = JustTheController();

  /// Author page data.
  Reference _reference = Reference.empty();

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    _tooltipController.dispose();
    _referenceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final bool canDeleteReference =
        userFirestoreSignal.value.rights.canManageReferences;

    return BasicShortcuts(
      onCancel: context.beamBack,
      child: Scaffold(
        body: CustomScrollView(slivers: [
          ApplicationBar(
            rightChildren: canDeleteReference
                ? ReferenceAppBarChildren.getChildren(
                    context,
                    tooltipController: _tooltipController,
                    onDeleteReference: onDeleteReference,
                  )
                : [],
          ),
          ReferencePageBody(
            reference: _reference,
            pageState: _pageState,
            onTapSeeQuotes: onTapSeeQuotes,
          ),
        ]),
      ),
    );
  }

  void fetch() async {
    setState(() => _pageState = EnumPageState.loading);

    await Future.wait([
      fetchReference(widget.referenceId),
      // fetchReferenceQuotes(widget.referenceId),
    ]);

    setState(() => _pageState = EnumPageState.idle);
  }

  DocumentMap getQuery(String referenceId) {
    return FirebaseFirestore.instance.collection("references").doc(referenceId);
  }

  Future fetchReference(String referenceId) async {
    if (referenceId == NavigationStateHelper.reference.id) {
      _reference = NavigationStateHelper.reference;
      _docRef =
          await getQuery(referenceId).get().then((value) => value.reference);
      listenToReference(getQuery(referenceId));
      return;
    }

    if (referenceId.isEmpty) {
      return;
    }

    try {
      final DocumentMap query = getQuery(referenceId);
      final DocumentSnapshotMap snapshot = await query.get();

      final Json? data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      data["id"] = snapshot.id;
      _reference = Reference.fromMap(data);
      _docRef = snapshot.reference;

      listenToReference(query);
    } catch (error) {
      loggy.error(error);
    }
  }

  Future fetchReferenceQuotes(String authorId) async {
    if (authorId.isEmpty) {
      return null;
    }

    try {
      final QueryMap query = FirebaseFirestore.instance
          .collection("quotes")
          .where("author.id", isEqualTo: authorId);

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.size == 0) {
        return;
      }

      for (final document in snapshot.docs) {
        final Json data = document.data();
        data["id"] = document.id;
        _referenceQuotes.add(Quote.fromMap(data));
      }
    } catch (error) {
      loggy.error(error);
    }
  }

  void listenToReference(DocumentMap query) {
    _referenceSubscription?.cancel();
    _referenceSubscription =
        query.snapshots().skip(1).listen((DocumentSnapshotMap authorSnapshot) {
      final Json? authorMap = authorSnapshot.data();
      if (!authorSnapshot.exists || authorMap == null) {
        _referenceSubscription?.cancel();
        navigateBack();
        return;
      }

      authorMap["id"] = authorSnapshot.id;
      final reference = Reference.fromMap(authorMap);

      setState(() {
        _reference = reference;
      });
    }, onError: (error) {
      loggy.error(error);
    }, onDone: () {
      _referenceSubscription?.cancel();
    });
  }

  /// Navigate back.
  void navigateBack() {
    if (context.canBeamBack) {
      context.beamBack();
      return;
    }

    context.beamToNamed(HomeLocation.route);
  }

  /// Callback fired to delete reference.
  void onDeleteReference() async {
    _tooltipController.hideTooltip();
    await _docRef?.delete();
    navigateBack();
  }

  void onTapSeeQuotes() {
    Beamer.of(context).beamToNamed(
      SearchLocation.route,
      routeState: {
        "query": "quotes:reference:${_reference.id}",
        "subjectName": _reference.name,
      },
    );
  }
}
