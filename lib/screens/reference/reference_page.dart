import "dart:async";
import "dart:math";
import "dart:ui" as ui;

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
import "package:text_wrap_auto_size/solution.dart";
import "package:text_wrap_auto_size/text_wrap_auto_size.dart";
import "package:vibration/vibration.dart";

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
  /// True if we already handled the quick action
  /// (e.g. pull/push to trigger).
  bool _handleQuickAction = false;

  /// Show reference metadata if true.
  bool _metadataOpened = true;

  /// Firestore quote document reference.
  DocumentReference? _docRef;

  /// Subscription to author data.
  DocSnapshotStreamSubscription? _referenceSubscription;

  /// Trigger offset for pull to action.
  final double _pullTriggerOffset = -110.0;

  /// List of quotes associated with the author.
  final List<Quote> _referenceQuotes = [];

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Tooltip controller.
  final JustTheController _tooltipController = JustTheController();

  /// Author page data.
  Reference _reference = Reference.empty();

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
    _tooltipController.dispose();
    _referenceSubscription?.cancel();
    _scrollController.dispose();
    _vibrationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Solution textWrapSolution = getTextSolution(windowSize);

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final bool canManageReference =
        userFirestoreSignal.value.rights.canManageReferences;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color randomColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: !isDark,
    );

    final EdgeInsets appbarPadding = Utils.graphic.isMobile()
        ? EdgeInsets.zero
        : const EdgeInsets.only(top: 18.0);

    return Scaffold(
      body: ImprovedScrolling(
        onScroll: onScroll,
        scrollController: _scrollController,
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
                rightChildren: ReferenceAppBarChildren.getChildren(
                  context,
                  isDark: isDark,
                  reference: _reference,
                  canManageReference: canManageReference,
                  tooltipController: _tooltipController,
                  onDeleteReference: onDeleteReference,
                  onTapPoster: onTapPoster,
                  onGoToEditPage: onEditReference,
                ),
              ),
              ReferencePageBody(
                areMetadataOpen: _metadataOpened,
                isDark: isDark,
                isMobileSize: isMobileSize,
                maxHeight: windowSize.height / 2,
                onTapSeeQuotes: onTapRelatedQuotes,
                pageState: _pageState,
                onDoubleTapName: onDoubleTapReferenceName,
                onDoubleTapSummary: onDoubleTapReferenceSummary,
                onTapPoster: onTapPoster,
                onToggleMetadata: onToggleReferenceMetadata,
                randomColor: randomColor,
                referenceNameTextStyle: textWrapSolution.style,
                reference: _reference,
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
      fetchReference(widget.referenceId),
    ]);

    startTextVibration();
    setState(() => _pageState = EnumPageState.idle);
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

  DocumentMap getQuery(String referenceId) {
    return FirebaseFirestore.instance.collection("references").doc(referenceId);
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
        Text(
          _reference.name,
          maxLines: 2,
          style: Utils.calligraphy.title(),
        ),
      );
    } catch (e) {
      loggy.error(e);
      return Solution(
        Text(_reference.name),
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

  /// Fetch reference data.
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

  /// Fetch reference quotes.
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
    _metadataOpened = await Utils.vault.getReferenceMetadataOpened();
  }

  /// Listen to reference changes.
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
      setState(() => _reference = Reference.fromMap(authorMap));
    }, onError: (error) {
      loggy.error(error);
    }, onDone: () {
      _referenceSubscription?.cancel();
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

  /// Callback fired to delete reference.
  void onDeleteReference() async {
    _tooltipController.hideTooltip();
    await _docRef?.delete();
    navigateBack();
  }

  /// Callback fired when reference name is double tapped.
  /// Copy name to clipboard.
  void onDoubleTapReferenceName() {
    Clipboard.setData(ClipboardData(text: _reference.name));
    Utils.graphic.showSnackbar(
      context,
      message: "reference.copy.success.name".tr(),
    );
  }

  /// Callback fired when reference summary is double tapped.
  /// Copy name to clipboard.
  void onDoubleTapReferenceSummary() {
    Clipboard.setData(ClipboardData(text: _reference.summary));
    Utils.graphic.showSnackbar(
      context,
      message: "reference.copy.success.summary".tr(),
    );
  }

  /// Callback fired to edit reference.
  void onEditReference() {
    NavigationStateHelper.reference = _reference;
    final String suffix = "edit/reference/${_reference.id}";
    Beamer.of(context).beamToNamed(
      getEditRoute(suffix),
      routeState: {
        "referenceName": _reference.name,
      },
    );
  }

  /// Callback fired to open image viewer.
  void onTapPoster(Reference reference) async {
    if (reference.urls.image.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "reference.error.no_image".tr(),
      );
      return;
    }

    final Image imageNetwork = Image.network(reference.urls.image);
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
    final double scaledRatio = min(ratio / (image.width / 900), 1.0);

    if (!mounted) return;
    Beamer.of(context, root: true).beamToNamed(
      HomeLocation.imageReferenceRoute
          .replaceFirst(":referenceId", reference.id),
      routeState: {
        "image-url": reference.urls.image,
        "hero-tag": reference.id,
        "title": reference.name,
        "id": reference.id,
        "init-scale": scaledRatio,
        "type": "reference",
      },
    );
  }

  /// Navigate to reference's quotes page.
  void onTapRelatedQuotes() {
    final BeamerDelegate beamer = Beamer.of(context);

    final bool hasSearch = beamer
        .beamingHistory.last.state.routeInformation.uri.pathSegments
        .contains("s");

    if (hasSearch) {
      beamer.beamToNamed(
        SearchLocation.route,
        routeState: {
          "query": "quotes:reference:${_reference.id}",
          "subjectName": _reference.name,
        },
        replaceRouteInformation: true,
      );
      return;
    }

    final bool hasDashboard = beamer
        .beamingHistory.last.state.routeInformation.uri.pathSegments
        .contains("d");

    if (hasDashboard) {
      beamer.beamToNamed(
        DashboardContentLocation.referenceQuotesRoute.replaceFirst(
          ":referenceId",
          _reference.id,
        ),
        routeState: {
          "referenceName": _reference.name,
        },
      );
      return;
    }

    beamer.beamToNamed(
      HomeContentLocation.referenceQuotesRoute.replaceFirst(
        ":referenceId",
        _reference.id,
      ),
      routeState: {
        "referenceName": _reference.name,
      },
    );
  }

  /// Callback fired to toggle reference metadata widget size.
  void onToggleReferenceMetadata() {
    Utils.vault.setReferenceMetadataOpened(!_metadataOpened);
    setState(() => _metadataOpened = !_metadataOpened);
  }

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

        Timer(Duration(milliseconds: 10 * _reference.summary.length), () {
          Vibration.cancel();
          _vibrationTimer?.cancel();
        });
      }
    });
  }
}
