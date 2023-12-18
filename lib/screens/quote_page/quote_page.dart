import "dart:async";
import "dart:io";

import "package:beamer/beamer.dart";
import "package:bottom_sheet/bottom_sheet.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/quote_page/quote_page_actions.dart";
import "package:kwotes/screens/quote_page/quote_page_body.dart";
import "package:kwotes/screens/quote_page/quote_page_container.dart";
import "package:kwotes/screens/quote_page/share_quote_bottom_sheet.dart";
import "package:kwotes/screens/quote_page/share_quote_template.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
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
import "package:share_plus/share_plus.dart";
import "package:text_wrap_auto_size/solution.dart";
import "package:text_wrap_auto_size/text_wrap_auto_size.dart";
import "package:unicons/unicons.dart";

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
  /// Quote data.
  Quote _quote = Quote.empty();

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

  /// Screenshot controller (to share quote image).
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Signal for navigation bar.
  /// This is used to hide/show the navigation bar.
  /// We store the variable on initialization because
  /// we'll need to access it on dispose
  /// (and we can't access context on dispoe).
  Signal<bool>? _signalNavigationBar;

  Solution _textWrapSolution = Solution(
    const Text(""),
    const TextStyle(),
    const Size(0, 0),
    const Size(0, 0),
  );

  /// Copy icon tooltip.
  String copyTooltip = "quote.copy.name".tr();

  /// Timer to temporarly swap copy icon.
  Timer? _timerCopyIcon;

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
  }

  @override
  void dispose() {
    _timerCopyIcon?.cancel();
    clean();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    const double widthPadding = 200.0;
    final double heightPadding = getHeightPadding();

    _textWrapSolution = TextWrapAutoSize.solution(
      Size(windowSize.width - widthPadding, windowSize.height - heightPadding),
      Text(_quote.name, style: Utils.calligraphy.body()),
    );

    final bool isMobileSize =
        windowSize.width < Utils.measurements.mobileWidthTreshold ||
            windowSize.height < Utils.measurements.mobileWidthTreshold;

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
                    onDoubleTapQuote: onCopyQuote,
                    onShareImage: onOpenShareImage,
                    onShareLink: onShareLink,
                    onShareText: onShareText,
                    onTapAuthor: onTapAuthor,
                    onTapReference: onTapReference,
                    pageState: _pageState,
                    quote: _quote,
                    selectedColor: getTopicColor(),
                    textWrapSolution: _textWrapSolution,
                    userFirestore: userFirestore,
                  ),
                  Positioned(
                    top: null,
                    // top: isMobileSize ? null : 16.0,
                    right: 0.0,
                    // right: 16.0,
                    // bottom: isMobileSize ? 16.0 : null,
                    bottom: 24.0,
                    // left: isMobileSize ? 0.0 : null,
                    left: 0.0,
                    child: QuotePageActions(
                      copyIcon: copyIcon,
                      direction: Axis.horizontal,
                      // direction: isMobileSize ? Axis.horizontal : Axis.vertical,
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
      _signalNavigationBar?.update((value) => true);
    }
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

      setState(() {
        _pageState = EnumPageState.idle;
      });

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

      setState(() {
        _pageState = EnumPageState.idle;
      });
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

  /// Generate file name for image to save on device.
  String generateFileName() {
    String name = "quote.name".tr();

    if (_quote.author.name.isNotEmpty) {
      name += " — ${_quote.author.name}";
    }

    if (_quote.reference.name.isNotEmpty) {
      name += " — ${_quote.reference.name}";
    }

    return name;
  }

  /// Get label value according to the current platform.
  /// e.g. "Share" for Android, iOS. "Download" for other platforms.
  String getFabLabelValue() {
    if (Platform.isAndroid || Platform.isIOS) {
      return "quote.share.image".tr();
    }

    return "download.name".tr();
  }

  /// Get icon data according to the current platform.
  /// e.g. "Share" for Android, iOS. "Download" for other platforms.
  IconData getFabIconData() {
    if (Platform.isAndroid || Platform.isIOS) {
      return TablerIcons.share;
    }

    return TablerIcons.download;
  }

  /// Returns the height padding for this widget according to available data
  /// (e.g. author, reference).
  double getHeightPadding() {
    double heightPadding = 400.0;
    // double heightPadding = 324.0;

    if (_quote.author.name.isNotEmpty) {
      heightPadding += 24.0;
    }

    if (_quote.author.urls.image.isNotEmpty) {
      heightPadding += 54.0;
    }

    if (_quote.reference.name.isNotEmpty) {
      heightPadding += 24.0;
    }

    return heightPadding;
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

  /// Initialize props.
  void initProps() {
    if (NavigationStateHelper.fullscreenQuotePage) {
      _signalNavigationBar = context.get<Signal<bool>>(
        EnumSignalId.navigationBar,
      );

      _signalNavigationBar?.update((value) => false);
    }
  }

  /// Callback fired to add quote to list.
  /// Opens the add to list dialog.
  void onAddToList() {
    final String userId =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value.id;

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    Utils.graphic.showAddToListDialog(
      context,
      isMobileSize: isMobileSize,
      quotes: [_quote],
      userId: userId,
      selectedColor: getTopicColor(),
    );
  }

  /// Callback fired to capture image and share it on mobile device,
  /// or download it on other platforms.
  /// [pop] if true, execute additional pop
  /// (to close previous bottom sheet on mobile).
  void onCaptureImage({bool pop = false}) {
    _screenshotController.capture().then((Uint8List? image) async {
      if (image == null) {
        return;
      }

      if (Platform.isAndroid || Platform.isIOS) {
        Share.shareXFiles(
          [
            XFile.fromData(
              image,
              name: "${generateFileName()}.png",
              mimeType: "image/png",
            ),
          ],
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 0, 0),
        );
        return;
      }

      final String? prefix = await FilePicker.platform.getDirectoryPath();

      if (prefix == null) {
        loggy.info("`prefix` is null probably because the user cancelled. "
            "Download cancelled.");

        if (!mounted) return;
        Utils.graphic.showSnackbar(
          context,
          message: "download.error.cancelled".tr(),
        );
        return;
      }

      final String path = "$prefix/${generateFileName()}.png";
      await File(path).writeAsBytes(image);
      if (!mounted) return;

      Utils.graphic.showSnackbar(
        context,
        message: "download.success".tr(),
      );

      if (pop) {
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      loggy.error(error);
      Utils.graphic.showSnackbar(
        context,
        message: "download.failed".tr(),
      );
    }).whenComplete(() => Navigator.of(context).pop());
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
    QuoteActions.copyQuote(quote);

    setState(() {
      copyIcon = UniconsLine.check;
      copyTooltip = "quote.copy.success.name".tr();
    });

    _timerCopyIcon?.cancel();
    _timerCopyIcon = Timer(
      const Duration(seconds: 3),
      () {
        setState(() {
          copyIcon = UniconsLine.copy;
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

  /// Callback fired to share quote.
  onShareQuote() {
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
          onShareImage: onOpenShareImage,
          onShareLink: onShareLink,
          onShareText: onShareText,
        );
      },
    );
  }

  /// Callback fired to share quote as image.
  /// [pop] indicates if a bottom sheet should be popped after sharing.
  void onOpenShareImage(Quote quote, {bool pop = false}) {
    showFlexibleBottomSheet(
      context: context,
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: 0.9,
      anchors: [0.0, 0.9],
      bottomSheetBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12.0),
        topRight: Radius.circular(12.0),
      ),
      builder: (
        BuildContext context,
        ScrollController scrollController,
        double bottomSheetOffset,
      ) {
        return ShareQuoteTemplate(
          borderColor: getTopicColor(),
          isMobileSize: Utils.measurements.isMobileSize(context),
          quote: quote,
          screenshotController: _screenshotController,
          textWrapSolution: _textWrapSolution,
          onBack: Navigator.of(context).pop,
          fabLabelValue: getFabLabelValue(),
          onTapShareImage: () => onCaptureImage(pop: pop),
          fabIconData: getFabIconData(),
          scrollController: scrollController,
          margin: const EdgeInsets.only(top: 24.0),
        );
      },
    );
  }

  /// Callback fired to share quote as link.
  void onShareLink(Quote quote) {
    if (kIsWeb || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      QuoteActions.copyQuoteUrl(quote);
      Utils.graphic.showSnackbar(
        context,
        message: "quote.copy_link.success".tr(),
      );
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      Share.shareUri(Uri.parse("${Constants.quoteUrl}/${_quote.id}"));
      return;
    }
  }

  /// Callback fired to share quote as text.
  void onShareText(Quote quote) {
    if (kIsWeb || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      onCopyQuote(quote);
      Utils.graphic.showSnackbar(
        context,
        message: "quote.copy.success.name".tr(),
      );
      return;
    }

    String textToShare = "«${_quote.name}»";

    if (quote.author.name.isNotEmpty) {
      textToShare += " — ${quote.author.name}";
    }

    if (quote.reference.name.isNotEmpty) {
      textToShare += " — ${quote.reference.name}";
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      Share.share(
        textToShare,
        subject: "quote.name".tr(),
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      return;
    }
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
    final Signal<UserFirestore> userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestore.value.id.isEmpty) {
      return;
    }

    if (_quote.starred) {
      setState(() {
        _quote = _quote.copyWith(starred: false);
      });

      final bool success = await QuoteActions.removeFromFavourites(
        quote: _quote,
        userId: userFirestore.value.id,
      );

      if (!success) {
        setState(() {
          _quote = _quote.copyWith(starred: true);
        });
      }

      return;
    }

    setState(() {
      _quote = _quote.copyWith(starred: true);
    });

    final bool success = await QuoteActions.addToFavourites(
      quote: _quote,
      userId: userFirestore.value.id,
    );

    if (!success) {
      setState(() {
        _quote = _quote.copyWith(starred: false);
      });
    }
  }
}
