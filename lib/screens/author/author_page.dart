import "dart:async";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_image_viewer/easy_image_viewer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
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
import "package:text_wrap_auto_size/solution.dart";
import "package:text_wrap_auto_size/text_wrap_auto_size.dart";

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

  /// Show author metadata if true.
  bool _metadataOpened = true;

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
    initProps();
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
    final Size windowSize = MediaQuery.of(context).size;
    final bool isMobileSize =
        windowSize.width < Utils.measurements.mobileWidthTreshold ||
            windowSize.height < Utils.measurements.mobileWidthTreshold;

    final Solution textWrapSolution = TextWrapAutoSize.solution(
      Size(windowSize.width - 48.0, windowSize.height / 3),
      Text(_author.name, style: Utils.calligraphy.title()),
    );

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final bool canManageAuthor =
        userFirestoreSignal.value.rights.canManageAuthors;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color randomColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: !isDark,
    );

    return BasicShortcuts(
      onCancel: context.beamBack,
      child: Scaffold(
        floatingActionButton: canManageAuthor
            ? FloatingActionButton(
                onPressed: onEditAuthor,
                backgroundColor: randomColor,
                foregroundColor: randomColor.computeLuminance() < 0.5
                    ? Colors.white
                    : Colors.black,
                child: const Icon(TablerIcons.pencil),
              )
            : null,
        body: CustomScrollView(
          slivers: [
            ApplicationBar(
              pinned: false,
              isMobileSize: isMobileSize,
              title: const SizedBox.shrink(),
              rightChildren: canManageAuthor
                  ? AuthorAppBarChildren.getChildren(
                      context,
                      tooltipController: _tooltipController,
                      onDeleteAuthor: onDeleteAuthor,
                    )
                  : [],
            ),
            AuthorPageBody(
              areMetadataOpen: _metadataOpened,
              authorNameTextStyle: textWrapSolution.style,
              author: _author,
              isDark: isDark,
              isMobileSize: isMobileSize,
              pageState: _pageState,
              maxHeight: windowSize.height / 2,
              onDoubleTapName: onDoubleTapAuthorName,
              onDoubleTapSummary: onDoubleTapAuthorSummary,
              onTapName: onTapAuthorName,
              onTapSeeQuotes: onTapSeeQuotes,
              onToggleMetadata: onToggleAuthorMetadata,
              randomColor: randomColor,
            ),
          ],
        ),
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

  /// Returns navigation route for the given suffix.
  /// This is necessary to keep the navigation context (e.g. home, search).
  /// E.g.: author/123 -> /h/author/123
  String getEditRoute(String suffix) {
    final BeamerDelegate beamer = Beamer.of(context);
    final BeamState beamState = beamer.currentBeamLocation.state as BeamState;
    final List<String> pathSegments = beamState.pathPatternSegments;
    final String prefix = pathSegments.first;
    return "/$prefix/$suffix";
  }

  /// Initialize properties.
  void initProps() async {
    _metadataOpened = await Utils.vault.getAuthorMetadataOpened();
  }

  /// Listen to author data.
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
      setState(() => _author = Author.fromMap(authorMap));
    }, onError: (error) {
      loggy.error(error);
    }, onDone: () {
      _authorSubscription?.cancel();
    });
  }

  /// Custom back navigation.
  /// If canBeamBack is true, then beam back.
  /// If canBeamBack is false, then go to home.
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

  /// Callback fired when author name is double tapped.
  /// Copy name to clipboard.
  void onDoubleTapAuthorName() {
    Clipboard.setData(ClipboardData(text: _author.name));
    Utils.graphic.showSnackbar(
      context,
      message: "author.copy.success.name".tr(),
    );
  }

  /// Callback fired when author summary is double tapped.
  /// Copy name to clipboard.
  void onDoubleTapAuthorSummary() {
    Clipboard.setData(ClipboardData(text: _author.summary));
    Utils.graphic.showSnackbar(
      context,
      message: "author.copy.success.summary".tr(),
    );
  }

  /// Callback fired to edit author.
  void onEditAuthor() {
    NavigationStateHelper.author = _author;
    final String suffix = "edit/author/${_author.id}";
    Beamer.of(context).beamToNamed(getEditRoute(suffix));
  }

  /// Callback fired when the author name is tapped.
  /// Opens an image viewer.
  void onTapAuthorName() {
    if (_author.urls.image.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "author.error.no_image".tr(),
      );
      return;
    }

    final ImageProvider imageProvider = Image.network(_author.urls.image).image;

    showImageViewer(
      context,
      doubleTapZoomable: true,
      imageProvider,
      immersive: false,
      swipeDismissible: true,
      useSafeArea: false,
    );
  }

  /// Callback fired to see author's quotes.
  void onTapSeeQuotes() {
    final BeamerDelegate beamer = Beamer.of(context);

    final bool hasSearch = beamer
        .beamingHistory.last.state.routeInformation.uri.pathSegments
        .contains("s");

    if (hasSearch) {
      beamer.beamToNamed(
        SearchContentLocation.route,
        routeState: {
          "query": "quotes:author:${_author.id}",
          "subjectName": _author.name,
        },
      );
      return;
    }

    beamer.beamToNamed(
      HomeContentLocation.authorQuotesRoute.replaceFirst(
        ":authorId",
        _author.id,
      ),
    );
  }

  /// Callback fired to toggle author metadata widget size.
  void onToggleAuthorMetadata() {
    Utils.vault.setAuthorMetadataOpened(!_metadataOpened);
    setState(() => _metadataOpened = !_metadataOpened);
  }
}
