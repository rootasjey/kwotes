import "dart:async";
import "dart:ui" as ui;
import "dart:math";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
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
import "package:vibration/vibration.dart";

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
  /// True if we already handled the quick action
  /// (e.g. pull/push to trigger).
  bool _handleQuickAction = false;

  /// Author page data.
  Author _author = Author.empty();

  /// Show author metadata if true.
  bool _metadataOpened = true;

  /// Firestore quote document reference.
  DocumentReference? _docRef;

  /// Subscription to author data.
  DocSnapshotStreamSubscription? _authorSubscription;

  /// Trigger offset for pull to action.
  final double _pullTriggerOffset = -110.0;

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Tooltip controller.
  final JustTheController _tooltipController = JustTheController();

  /// List of quotes associated with the author.
  final List<Quote> _authorQuotes = [];

  /// Scroll controller.
  final ScrollController _scrollController = ScrollController();

  /// Timer to vibrate when quote is displayed.
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
  }

  @override
  void dispose() {
    _vibrationTimer?.cancel();
    _tooltipController.dispose();
    _authorSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Solution textWrapSolution = getTextSolution(windowSize);

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final bool canManageAuthor =
        userFirestoreSignal.value.rights.canManageAuthors;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: !isDark,
    );

    final EdgeInsets appbarPadding = Utils.graphic.isMobile()
        ? EdgeInsets.zero
        : const EdgeInsets.only(top: 18.0);

    return Scaffold(
      body: ImprovedScrolling(
        scrollController: _scrollController,
        onScroll: onScroll,
        child: ScrollConfiguration(
          behavior: const CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              ApplicationBar(
                pinned: false,
                toolbarHeight: 48.0,
                isMobileSize: isMobileSize,
                hideIcon: true,
                padding: appbarPadding,
                title: const SizedBox.shrink(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                rightChildren: AuthorAppBarChildren.getChildren(
                  context,
                  isDark: isDark,
                  canManageAuthor: canManageAuthor,
                  tooltipController: _tooltipController,
                  onDeleteAuthor: onDeleteAuthor,
                  author: _author,
                  onTapAvatar: onTapAvatar,
                  onGoToEditPage: onEditAuthor,
                ),
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
                onTapAvatar: onTapAvatar,
                onTapSeeQuotes: onTapRelatedQuotes,
                onToggleMetadata: onToggleAuthorMetadata,
                randomColor: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Set the target variable to the new value.
  /// Then set the value back to its original value after 1 second.
  void boomerangQuickActionValue(bool newValue) {
    _handleQuickAction = newValue;
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _handleQuickAction = !newValue,
    );
  }

  void fetch() async {
    setState(() => _pageState = EnumPageState.loading);

    await Future.wait([
      fetchAuthor(widget.authorId),
    ]);

    startTextVibration();
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

  /// Get text height based on window size.
  double getTextHeight(Size windowSize) {
    final double maxHeight = windowSize.height / 6;
    return min(windowSize.height / 3, maxHeight);
  }

  /// Get text height based on window size.
  double getTextWidth(Size windowSize) {
    return min(windowSize.width - 54.0, 200.0);
  }

  /// Get text solution (style) based on window size.
  Solution getTextSolution(Size windowSize) {
    final double height = getTextHeight(windowSize);
    final double width = getTextWidth(windowSize);

    try {
      return TextWrapAutoSize.solution(
        Size(width, height),
        Text(_author.name, style: Utils.calligraphy.title()),
      );
    } catch (e) {
      loggy.error(e);
      return Solution(
        Text(
          _author.name,
          maxLines: 1,
        ),
        Utils.calligraphy.title(
          textStyle: const TextStyle(
            fontSize: 54.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Size(width, height),
        Size(width, height),
      );
    }
  }

  /// Trigger an action on pull gesture.
  void handlePullQuickAction() {
    final double pixelsPosition = _scrollController.position.pixels;

    if (pixelsPosition < _scrollController.position.minScrollExtent) {
      if (pixelsPosition < _pullTriggerOffset && !_handleQuickAction) {
        boomerangQuickActionValue(true);
        context.beamBack();
      }
      return;
    }
  }

  /// Initialize properties.
  void initProps() async {
    _metadataOpened = await Utils.vault.getAuthorMetadataOpened();
  }

  /// Listen to author changes.
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
    Beamer.of(context).beamToNamed(
      getEditRoute(suffix),
      routeState: {
        "authorName": _author.name,
      },
    );
  }

  /// Callback fired when the author name is tapped.
  /// Opens an image viewer.
  void onTapAvatar() async {
    if (_author.urls.image.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "author.error.no_image".tr(),
      );
      return;
    }

    final Image imageNetwork = Image.network(_author.urls.image);
    Completer<ui.Image> completer = Completer<ui.Image>();
    imageNetwork.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      final ui.Image image = info.image;
      info.image.height;
      completer.complete(image);
    }));

    final ui.Image image = await completer.future;
    final double ratio = image.width / image.height;
    final double scaledRatio = min(ratio / (image.width / 900), 1.7);

    if (!mounted) return;
    Beamer.of(context, root: true).beamToNamed(
      HomeLocation.imageAuthorRoute.replaceFirst(":authorId", _author.id),
      routeState: {
        "image-url": _author.urls.image,
        "hero-tag": _author.id,
        "title": _author.name,
        "id": _author.id,
        "init-scale": scaledRatio,
        "type": "author",
      },
    );
  }

  /// Callback fired to see author's quotes.
  void onTapRelatedQuotes() {
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

    final bool hasDashboard = beamer
        .beamingHistory.last.state.routeInformation.uri.pathSegments
        .contains("d");

    if (hasDashboard) {
      beamer.beamToNamed(
          DashboardContentLocation.authorQuotesRoute.replaceFirst(
            ":authorId",
            _author.id,
          ),
          routeState: {
            "authorName": _author.name,
          });
      return;
    }

    beamer.beamToNamed(
        HomeContentLocation.authorQuotesRoute.replaceFirst(
          ":authorId",
          _author.id,
        ),
        routeState: {
          "authorName": _author.name,
        });
  }

  /// Callback fired to toggle author metadata widget size.
  void onToggleAuthorMetadata() {
    Utils.vault.setAuthorMetadataOpened(!_metadataOpened);
    setState(() => _metadataOpened = !_metadataOpened);
  }

  /// Callback fired while scrolling.
  void onScroll(double offset) {
    handlePullQuickAction();
  }

  /// Start text vibration while animating.
  void startTextVibration() {
    Vibration.cancel();
    Vibration.hasVibrator().then((bool? hasVibrator) {
      if (hasVibrator ?? false) {
        _vibrationTimer = Timer.periodic(
          const Duration(milliseconds: 50),
          (Timer timer) {
            Vibration.vibrate(
              pattern: [100, 14],
              intensities: [10, 30],
            );
          },
        );

        Timer(Duration(milliseconds: 10 * _author.summary.length), () {
          Vibration.cancel();
          _vibrationTimer?.cancel();
        });
      }
    });
  }
}
