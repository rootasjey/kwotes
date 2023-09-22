import "dart:async";

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
import "package:kwotes/screens/author/author_app_bar_children.dart";
import "package:kwotes/screens/author/author_page_body.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/doc_snapshot_stream_subscription.dart";
import "package:kwotes/types/firestore/document_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

class AuthorPage extends StatefulWidget {
  const AuthorPage({
    super.key,
    required this.authorId,
  });

  /// Unique id of the author.
  final String authorId;

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> with UiLoggy {
  /// Author page data.
  Author _author = Author.empty();

  /// Firestore quote document reference.
  DocumentReference? _docRef;

  /// Subscription to author data.
  DocSnapshotStreamSubscription? _authorSubscription;

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Tooltip controller.
  final JustTheController _tooltipController = JustTheController();

  /// List of quotes associated with the author.
  final List<Quote> _authorQuotes = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    _tooltipController.dispose();
    _authorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final bool canDeleteAuthor =
        userFirestoreSignal.value.rights.canManageAuthors;

    return BasicShortcuts(
      onCancel: context.beamBack,
      child: Scaffold(
        body: CustomScrollView(slivers: [
          ApplicationBar(
            rightChildren: canDeleteAuthor
                ? AuthorAppBarChildren.getChildren(
                    context,
                    tooltipController: _tooltipController,
                    onDeleteAuthor: onDeleteAuthor,
                  )
                : [],
          ),
          AuthorPageBody(
            author: _author,
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
      fetchAuthor(widget.authorId),
      // fetchAuthorQuotes(widget.authorId),
    ]);

    setState(() => _pageState = EnumPageState.idle);
  }

  DocumentMap getQuery(String authorId) {
    return FirebaseFirestore.instance.collection("authors").doc(authorId);
  }

  Future fetchAuthor(String authorId) async {
    if (authorId == NavigationStateHelper.author.id) {
      _author = NavigationStateHelper.author;
      _docRef = await getQuery(authorId).get().then((value) => value.reference);
      listenToAuthor(getQuery(authorId));
      return;
    }

    if (authorId.isEmpty) {
      return;
    }

    try {
      final DocumentMap query = getQuery(authorId);
      final DocumentSnapshotMap snapshot = await query.get();

      final Json? data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }

      data["id"] = snapshot.id;
      _author = Author.fromMap(data);
      _docRef = snapshot.reference;

      listenToAuthor(query);
    } catch (error) {
      loggy.error(error);
    }
  }

  Future fetchAuthorQuotes(String authorId) async {
    if (authorId.isEmpty) {
      return null;
    }

    try {
      final QueryMap query = FirebaseFirestore.instance
          .collection("quotes")
          .where("author.id", isEqualTo: authorId)
          .orderBy("created_at", descending: true)
          .limit(20);

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.size == 0) {
        return;
      }

      for (final document in snapshot.docs) {
        final Json data = document.data();
        data["id"] = document.id;
        _authorQuotes.add(Quote.fromMap(data));
      }
    } catch (error) {
      loggy.error(error);
    }
  }

  void listenToAuthor(DocumentMap query) {
    _authorSubscription?.cancel();
    _authorSubscription =
        query.snapshots().skip(1).listen((DocumentSnapshotMap authorSnapshot) {
      final Json? authorMap = authorSnapshot.data();
      if (!authorSnapshot.exists || authorMap == null) {
        _authorSubscription?.cancel();
        navigateBack();
        return;
      }

      authorMap["id"] = authorSnapshot.id;
      final author = Author.fromMap(authorMap);

      setState(() {
        _author = author;
      });
    }, onError: (error) {
      loggy.error(error);
    }, onDone: () {
      _authorSubscription?.cancel();
    });
  }

  void navigateBack() {
    if (context.canBeamBack) {
      context.beamBack();
      return;
    }

    context.beamToNamed(HomeLocation.route);
  }

  /// Callback fired to delete draft.
  void onDeleteAuthor() async {
    _tooltipController.hideTooltip();
    await _docRef?.delete();
    navigateBack();
  }

  void onTapSeeQuotes() {
    Beamer.of(context).beamToNamed(
      SearchLocation.route,
      routeState: {
        "query": "quotes:author:${_author.id}",
        "subjectName": _author.name,
      },
    );
  }
}
