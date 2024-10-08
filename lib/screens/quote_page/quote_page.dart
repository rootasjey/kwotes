import "dart:async";

import "package:beamer/beamer.dart";
import "package:bottom_sheet/bottom_sheet.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/quote_page/explain_quote_sheet.dart";
import "package:kwotes/screens/quote_page/quote_page_actions.dart";
import "package:kwotes/screens/quote_page/quote_page_body.dart";
import "package:kwotes/screens/quote_page/quote_page_container.dart";
import "package:kwotes/screens/quote_page/share_quote_bottom_sheet.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_draft_quote_operation.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/intents/add_to_list_intent.dart";
import "package:kwotes/types/intents/copy_intent.dart";
import "package:kwotes/types/intents/like_intent.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/user/user_rights.dart";
import "package:loggy/loggy.dart";
import "package:screenshot/screenshot.dart";
import "package:text_wrap_auto_size/solution.dart";
import "package:vibration/vibration.dart";

class QuotePage extends StatefulWidget {
  const QuotePage({
    super.key,
    required this.quoteId,
  });

  /// Unique id of the quote.
  final String quoteId;

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> with UiLoggy {
  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Copy icon data.
  IconData copyIcon = TablerIcons.copy;

  /// Keyboard shortcuts.
  final Map<LogicalKeySet, Intent> _shortcuts = {
    LogicalKeySet(LogicalKeyboardKey.keyC): const CopyIntent(),
    LogicalKeySet(LogicalKeyboardKey.keyA): const AddToListIntent(),
    LogicalKeySet(LogicalKeyboardKey.keyL): const LikeIntent(),
  };

  /// Quote data.
  Quote _quote = Quote.empty();

  /// Screenshot controller (to share quote image).
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Signal for navigation bar.
  /// This is used to hide/show the navigation bar.
  /// We store the variable on initialization because
  /// we'll need to access it on dispose
  /// (and we can't access context on dispoe).
  Signal<bool>? _signalNavigationBar;

  /// Text wrap solution to calculate font size according to window size.
  Solution _textWrapSolution = Solution(
    const Text(""),
    const TextStyle(),
    const Size(0, 0),
    const Size(0, 0),
  );

  /// Collection name.
  final String _collectionName = "quotes";

  /// Copy icon tooltip.
  String copyTooltip = "quote.copy.name".tr();

  /// Timer to temporarly swap copy icon.
  Timer? _timerCopyIcon;

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
    _timerCopyIcon?.cancel();
    _vibrationTimer?.cancel();
    clean();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    final Size quoteContainerSize = computeWindowSize(windowSize);

    _textWrapSolution = Utils.graphic.getTextSolution(
      quote: _quote,
      windowSize: quoteContainerSize,
      style: Utils.calligraphy.body(),
      maxFontSize: windowSize.width < 300 ? 35.0 : 35.0,
    );

    final bool isMobileSize =
        quoteContainerSize.width < Utils.measurements.mobileWidthTreshold ||
            quoteContainerSize.height < Utils.measurements.mobileWidthTreshold;

    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    return BasicShortcuts(
      onCancel: () => Utils.passage.deepBack(context),
      additionalShortcuts: _shortcuts,
      additionalActions: {
        CopyIntent: CallbackAction<CopyIntent>(
          onInvoke: (CopyIntent intent) => onCopyQuote(_quote),
        ),
        AddToListIntent: CallbackAction<AddToListIntent>(
          onInvoke: (AddToListIntent intent) => onAddToList(),
        ),
        LikeIntent: CallbackAction<LikeIntent>(
          onInvoke: (LikeIntent intent) => onToggleFavourite(),
        ),
      },
      child: SafeArea(
        child: QuotePageContainer(
          borderColor: getTopicColor(),
          heroTag: widget.quoteId,
          isMobileSize: isMobileSize,
          onTapOutsideChild: () => Utils.passage.deepBack(context),
          child: SignalBuilder(
            signal: signalUserFirestore,
            builder: (
              BuildContext context,
              UserFirestore userFirestore,
              Widget? child,
            ) {
              final UserRights userRights = userFirestore.rights;
              final bool canManageQuotes = userRights.canManageQuotes;
              final void Function(Quote quote, String language)?
                  onChangeLanguage =
                  canManageQuotes ? onChangeQuoteLanguage : null;

              return Stack(
                children: [
                  QuotePageBody(
                    authenticated: userFirestore.id.isNotEmpty,
                    onChangeLanguage: onChangeLanguage,
                    onCopyQuote: onCopyQuote,
                    onCopyAuthor: onCopyAuthorName,
                    onCopyAuthorUrl: onCopyAuthorUrl,
                    onCopyQuoteUrl: QuoteActions.copyQuoteUrl,
                    onCopyReference: onCopyReference,
                    onCopyReferenceUrl: onCopyReferenceUrl,
                    onDeleteQuote: canManageQuotes ? onDeleteQuote : null,
                    onDoubleTapQuote: onCopyQuote,
                    onEditQuote: canManageQuotes ? onEditQuote : null,
                    onExplainQuote: onExplainQuote,
                    onFinishedAnimation: stopVibrationTimer,
                    onShareImage: onShareImage,
                    onShareLink: onShareLink,
                    onShareText: onShareText,
                    onTapAuthor: onTapAuthor,
                    onTapReference: onTapReference,
                    pageState: _pageState,
                    quote: _quote,
                    selectedColor: getTopicColor(),
                    textWrapSolution: _textWrapSolution,
                    userFirestore: userFirestore,
                    windowSize: windowSize,
                  ),
                  Positioned(
                    top: null,
                    right: 0.0,
                    bottom: 24.0,
                    left: 0.0,
                    child: QuotePageActions(
                      copyIcon: copyIcon,
                      direction: Axis.horizontal,
                      authenticated: userFirestore.id.isNotEmpty,
                      quote: _quote,
                      copyTooltip: copyTooltip,
                      minimal: NavigationStateHelper.minimalQuoteActions,
                      onCopyQuote: onCopyQuote,
                      onShareQuote: onShareQuote,
                      onToggleFavourite: onToggleFavourite,
                      onNavigateBack: () => Utils.passage.deepBack(context),
                      onAddToList: onAddToList,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Clean up resources.
  void clean() {
    if (!mounted) return;
    if (NavigationStateHelper.fullscreenQuotePage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _signalNavigationBar?.updateValue((value) => true);
      });
    }
  }

  /// Calculate actual quote container size based on screen size.
  Size computeWindowSize(Size size) {
    const double paddingValue = 54.0;

    if (NavigationStateHelper.isIpad) {
      return Size(
        (size.width * 0.7) - paddingValue,
        (size.height * 0.5) - paddingValue,
      );
    }

    if (size.width < 500 && size.height > 500) {
      return Size(
        (size.width * 0.8) - paddingValue,
        (size.height * 0.8) - paddingValue,
      );
    }

    if (size.width < 900 && size.height < 900) {
      return Size(
        (size.width) - paddingValue,
        (size.height) - paddingValue,
      );
    }

    return Size(
      (size.width * 0.7) - paddingValue,
      (size.height * 0.6) - paddingValue,
    );
  }

  /// Fetch page data.
  void fetch() {
    setState(() => _pageState = EnumPageState.loading);
    fetchQuote();
  }

  /// Fetch quote's author.
  Future<Author?> fetchAuthor(String authorId) async {
    if (authorId.isEmpty) {
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("authors")
          .doc(authorId)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      data["id"] = snapshot.id;
      return Author.fromMap(data);
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  /// Fetch quote's reference.
  Future<Reference?> fetchReference(String referenceId) async {
    if (referenceId.isEmpty) {
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("references")
          .doc(referenceId)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      data["id"] = snapshot.id;
      return Reference.fromMap(data);
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  /// Fetch quote's author and reference.
  Future<void> fetchAuthorAndRef(Quote quote) async {
    final List<Object?> results = await Future.wait([
      fetchAuthor(quote.author.id),
      fetchReference(quote.reference.id),
    ]);

    final Author? resultAuthor = results.first as Author?;
    final Reference? resultReference = results.last as Reference?;

    if (resultAuthor != null) {
      _quote = _quote.copyWith(author: resultAuthor);
    }
    if (resultReference != null) {
      _quote = _quote.copyWith(reference: resultReference);
    }

    if (!mounted) return;
    setState(() {});
  }

  /// Fetch quote data.
  /// Skip the operation if we have the quote already (in NavigationStateHelper).
  void fetchQuote() async {
    if (widget.quoteId == NavigationStateHelper.quote.id) {
      final bool starred = await fetchIsFavourite(widget.quoteId);
      _quote = NavigationStateHelper.quote.copyWith(
        starred: starred,
      );

      await fetchAuthorAndRef(_quote);

      setState(() => _pageState = EnumPageState.idle);
      startTextVibration();
      return;
    }

    try {
      final DocumentSnapshotMap snapshot = await FirebaseFirestore.instance
          .collection("quotes")
          .doc(widget.quoteId)
          .get();

      final Json? data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }

      data["id"] = snapshot.id;
      data["starred"] = await fetchIsFavourite(snapshot.id);
      _quote = Quote.fromMap(data);

      await fetchAuthorAndRef(_quote);

      setState(() => _pageState = EnumPageState.idle);
      startTextVibration();
    } catch (error) {
      loggy.error(error);
      _pageState = EnumPageState.error;
    }
  }

  /// Returns true if the quote is starred by the current user.
  Future<bool> fetchIsFavourite(String quoteId) async {
    final Signal<UserFirestore> userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestore.value.id.isEmpty) {
      return false;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userFirestore.value.id)
          .collection("favourites")
          .doc(quoteId)
          .get();

      return snapshot.exists;
    } catch (error) {
      loggy.error(error);
      return false;
    }
  }

  /// Returns navigation route for the given suffix.
  /// This is necessary to keep the navigation context (e.g. home, search).
  /// E.g.: author/123 -> /h/author/123
  String getRoute(String suffix) {
    final BeamerDelegate beamer = Beamer.of(context);
    final BeamState beamState = beamer.currentBeamLocation.state as BeamState;
    final List<String> pathSegments = beamState.pathPatternSegments;
    final String prefix = pathSegments.first;
    return "/$prefix/$suffix";
  }

  /// Returns quote first topic color, if any.
  Color getTopicColor() {
    if (_quote.topics.isEmpty) {
      return Colors.indigo.shade200;
    }

    return Constants.colors.getColorFromTopicName(
      context,
      topicName: _quote.topics.first,
    );
  }

  /// Open a bottom sheet to explain the quote.
  void onExplainQuote() async {
    showFlexibleBottomSheet(
      context: context,
      minHeight: 0,
      initHeight: 0.9,
      maxHeight: 1.0,
      isSafeArea: true,
      anchors: [0.0, 0.9],
      bottomSheetColor: Colors.white,
      bottomSheetBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12.0),
        topRight: Radius.circular(12.0),
      ),
      builder: (
        BuildContext context,
        ScrollController scrollController,
        double bottomSheetOffset,
      ) {
        return ExplainQuoteSheet(
          quote: _quote,
          scrollController: scrollController,
        );
      },
    );
  }

  /// Initialize props.
  void initProps() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (NavigationStateHelper.fullscreenQuotePage) {
        _signalNavigationBar = context.get<Signal<bool>>(
          EnumSignalId.navigationBar,
        );

        _signalNavigationBar?.updateValue((value) => false);
      }
    });
  }

  bool isUserPremium() {
    final UserFirestore userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value;

    if (userFirestore.plan == EnumUserPlan.free) {
      Beamer.of(context, root: true).beamToNamed(
        HomeLocation.premiumRoute,
      );
      return false;
    }

    return true;
  }

  /// Check if user is signed in or not.
  /// If not, navigate back to connection page.
  /// If yes, do nothing.
  bool isUserSignIn() {
    final UserFirestore userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value;

    if (userFirestore.id.isNotEmpty) {
      return true;
    }

    context.beamBack();
    context.get<Signal<String>>(EnumSignalId.navigationBarPath).updateValue(
        (prevValue) => "${DashboardLocation.route}-${DateTime.now()}");

    return false;
  }

  /// Callback fired to add quote to list.
  /// Opens the add to list dialog.
  void onAddToList() {
    Utils.graphic.tapVibration();
    final UserFirestore userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value;

    if (!isUserSignIn()) return;

    final String userId = userFirestore.id;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    Utils.graphic.showAddToListDialog(
      context,
      isMobileSize: isMobileSize || NavigationStateHelper.isIpad,
      isIpad: NavigationStateHelper.isIpad,
      quotes: [_quote],
      userId: userId,
      selectedColor: getTopicColor(),
    );
  }

  /// Callback to update a quote's language.
  void onChangeQuoteLanguage(Quote quote, String language) async {
    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final UserRights userRights = currentUser.value.rights;
    final bool canManageQuotes = userRights.canManageQuotes;

    if (!canManageQuotes) {
      return;
    }

    if (language == quote.language) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("quotes")
          .doc(quote.id)
          .update({"language": language});
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: "quote.update.failed".tr(),
      );
    }
  }

  /// Callback fired to copy quote's name.
  void onCopyQuote(Quote quote) {
    Utils.graphic.tapVibration();
    QuoteActions.copyQuote(quote);

    setState(() {
      copyIcon = TablerIcons.check;
      copyTooltip = "quote.copy.success.name".tr();
    });

    _timerCopyIcon?.cancel();
    _timerCopyIcon = Timer(
      const Duration(seconds: 3),
      () {
        setState(() {
          copyIcon = TablerIcons.copy;
          copyTooltip = "quote.copy.name".tr();
        });
      },
    );
  }

  /// Callback fired to copy reference's name.
  void onCopyReference() {
    Clipboard.setData(ClipboardData(text: _quote.reference.name));
  }

  /// Callback fired to copy author name.
  void onCopyAuthorName(Author author) {
    Clipboard.setData(ClipboardData(text: author.name));
  }

  /// Callback fired to author url.
  void onCopyAuthorUrl(Author author) {
    Clipboard.setData(
        ClipboardData(text: "${Constants.authorUrl}/${author.id}"));
  }

  /// Callback fired to copy reference url.
  void onCopyReferenceUrl() {
    Clipboard.setData(ClipboardData(
        text: "${Constants.referenceUrl}/${_quote.reference.id}"));
  }

  /// Callback to delete a published quote.
  void onDeleteQuote(Quote quote) async {
    final Signal<UserFirestore> currentUser =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final UserRights userRights = currentUser.value.rights;
    final bool canManageQuotes = userRights.canManageQuotes;

    if (!canManageQuotes) return;

    try {
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(quote.id)
          .delete();

      loggy.info("will delete quote: ${quote.id}");

      if (!mounted) return;
      Utils.graphic.showSnackbarWithCustomText(
        context,
        duration: const Duration(seconds: 10),
        text: Row(children: [
          Expanded(
            flex: 0,
            child: Text(
              "quote.delete.success".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.6),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection(_collectionName)
                    .doc(quote.id)
                    .set(quote.toMap(
                      operation: EnumQuoteOperation.restore,
                    ));

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                loggy.info("reverse add quote: ${quote.id}");
              },
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                fontSize: 16.0,
              )),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "rollback".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(TablerIcons.rotate_2),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );

      context.beamBack();
    } catch (error) {
      loggy.error(error);
      Utils.graphic.showSnackbar(context, message: "error");
    }
  }

  /// Callback to edit a published quote.
  void onEditQuote(Quote quote) {
    NavigationStateHelper.quote = quote;
    context.beamToNamed(
      getRoute("edit/quote/${quote.id}"),
      data: {
        "quoteId": quote.id,
      },
    );
  }

  /// Callback fired when text animation is finished.
  void stopVibrationTimer() async {
    if (!Utils.graphic.isMobile()) return;
    if (await Vibration.hasVibrator() ?? false) {
      return;
    }

    Vibration.cancel();
    _vibrationTimer?.cancel();

    Future.delayed(const Duration(milliseconds: 90), () {
      Vibration.vibrate(
        pattern: [40, 0, 40, 0],
        intensities: [40, 0, 40, 0],
      );
    });
  }

  /// Callback fired to share quote.
  void onShareQuote() {
    Utils.graphic.tapVibration();
    if (!isUserSignIn()) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (BuildContext context) {
        return ShareQuoteBottomSheet(
          quote: _quote,
          onShareImage: onShareImage,
          onShareLink: (Quote quote) => Utils.graphic.onShareLink(
            context,
            quote: quote,
          ),
          onShareText: (Quote quote) => Utils.graphic.onShareText(
            context,
            quote: quote,
            onCopyQuote: onCopyQuote,
          ),
        );
      },
    );
  }

  void onShareImage(Quote quote, {bool pop = true}) {
    if (!isUserPremium()) return;
    Utils.graphic.onOpenShareImage(
      context,
      pop: pop,
      quote: quote,
      screenshotController: _screenshotController,
      textWrapSolution: _textWrapSolution,
      mounted: mounted,
    );
  }

  void onShareLink(Quote quote) {
    Utils.graphic.onShareLink(
      context,
      quote: quote,
    );
  }

  void onShareText(Quote quote) {
    Utils.graphic.onShareText(
      context,
      quote: quote,
      onCopyQuote: onCopyQuote,
    );
  }

  /// Callback fired to navigate to author page.
  void onTapAuthor(Author author) {
    NavigationStateHelper.author = author;
    final String suffix = "author/${author.id}";
    Beamer.of(context).beamToNamed(getRoute(suffix));
  }

  /// Callback fired to navigate to reference page.
  void onTapReference(Reference reference) {
    NavigationStateHelper.reference = reference;
    final String suffix = "reference/${reference.id}";
    Beamer.of(context).beamToNamed(getRoute(suffix));
  }

  /// Callback fired to toggle quote's favourite status
  /// from the current authenticated user perspective.
  void onToggleFavourite() async {
    Utils.graphic.tapVibration();
    final UserFirestore userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value;

    if (!isUserSignIn()) return;
    if (_quote.starred) {
      setState(() => _quote = _quote.copyWith(starred: false));
      final bool success = await QuoteActions.removeFromFavourites(
        quote: _quote,
        userId: userFirestore.id,
      );

      if (!success) {
        setState(() => _quote = _quote.copyWith(starred: true));
      }

      return;
    }

    setState(() => _quote = _quote.copyWith(starred: true));
    final bool success = await QuoteActions.addToFavourites(
      quote: _quote,
      userId: userFirestore.id,
    );

    if (!success) {
      setState(() => _quote = _quote.copyWith(starred: false));
    }
  }

  /// Start text vibration while animating.
  void startTextVibration() async {
    if (!Utils.graphic.isMobile()) return;
    if (await Vibration.hasVibrator() ?? false) {
      return;
    }

    Vibration.cancel();
    Vibration.hasVibrator().then((bool? hasVibrator) {
      if (hasVibrator ?? false) {
        _vibrationTimer = Timer.periodic(
          const Duration(milliseconds: 50),
          (Timer timer) {
            Vibration.vibrate(
              pattern: [50],
              intensities: [50],
            );
          },
        );
      }
    });
  }
}
