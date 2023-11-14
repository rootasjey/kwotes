import "dart:async";

import "package:beamer/beamer.dart";
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
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/home/quote_page_actions.dart";
import "package:kwotes/screens/home/quote_page_body.dart";
import "package:kwotes/screens/home/quote_page_container.dart";
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
import "package:kwotes/types/topic.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";
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

  final Map<LogicalKeySet, Intent> _shortcuts = {
    LogicalKeySet(LogicalKeyboardKey.keyC): const CopyIntent(),
    LogicalKeySet(LogicalKeyboardKey.keyA): const AddToListIntent(),
    LogicalKeySet(LogicalKeyboardKey.keyL): const LikeIntent(),
  };

  /// Signal for navigation bar.
  /// This is used to hide/show the navigation bar.
  /// We store the variable on initialization because
  /// we'll need to access it on dispose
  /// (and we can't access context on dispoe).
  Signal<bool>? _signalNavigationBar;

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
    double widthPadding = 192.0;
    double heightPadding = getHeightPadding();

    final Solution textWrapSolution = TextWrapAutoSize.solution(
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
          onInvoke: (CopyIntent intent) => onCopyQuote(),
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
              return Stack(
                children: [
                  QuotePageBody(
                    authenticated: userFirestore.id.isNotEmpty,
                    pageState: _pageState,
                    quote: _quote,
                    onDoubleTapQuote: onCopyQuote,
                    onCopyQuote: onCopyQuote,
                    onCopyAuthor: onCopyAuthorName,
                    onCopyReference: onCopyReference,
                    onTapAuthor: onTapAuthor,
                    onTapReference: onTapReference,
                    onCopyQuoteUrl: onCopyQuoteUrl,
                    onCopyAuthorUrl: onCopyAuthorUrl,
                    onCopyReferenceUrl: onCopyReferenceUrl,
                    textWrapSolution: textWrapSolution,
                    userFirestore: userFirestore,
                  ),
                  Positioned(
                    top: isMobileSize ? null : 24.0,
                    right: isMobileSize ? 0.0 : 24.0,
                    bottom: isMobileSize ? 24.0 : null,
                    left: isMobileSize ? 0.0 : null,
                    child: QuotePageActions(
                      copyIcon: copyIcon,
                      direction: isMobileSize ? Axis.horizontal : Axis.vertical,
                      authenticated: userFirestore.id.isNotEmpty,
                      quote: _quote,
                      copyTooltip: copyTooltip,
                      onCopyQuote: onCopyQuote,
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
    setState(() {
      _pageState = EnumPageState.loading;
    });

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

  /// Returns the height padding for this widget according to available data
  /// (e.g. author, reference).
  double getHeightPadding() {
    double heightPadding = 158.0;

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

    final String firstTopic = _quote.topics.first;
    final topic = Constants.colors.topics.firstWhere(
      (element) => element.name == firstTopic,
      orElse: () {
        return Topic.empty();
      },
    );

    if (topic.name.isEmpty) {
      return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    }

    return topic.color;
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

  /// Callback fired to copy quote's name.
  void onCopyQuote() {
    QuoteActions.copyQuote(_quote);

    setState(() {
      copyIcon = UniconsLine.check;
      copyTooltip = "quote.copy.success".tr();
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

  /// Callback fired to copy reference's name.
  void onCopyReference() {
    Clipboard.setData(ClipboardData(text: _quote.reference.name));
  }

  /// Callback fired to copy author name.
  void onCopyAuthorName() {
    Clipboard.setData(ClipboardData(text: _quote.author.name));
  }

  /// Callback fired to author url.
  void onCopyAuthorUrl() {
    Clipboard.setData(
        ClipboardData(text: "${Constants.authorUrl}/${_quote.author.id}"));
  }

  /// Callback fired to copy quote url.
  void onCopyQuoteUrl() {
    Clipboard.setData(
        ClipboardData(text: "${Constants.quoteUrl}/${_quote.id}"));
  }

  /// Callback fired to copy reference url.
  void onCopyReferenceUrl() {
    Clipboard.setData(ClipboardData(
        text: "${Constants.referenceUrl}/${_quote.reference.id}"));
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
      quote: _quote,
      userId: userId,
    );
  }
}
