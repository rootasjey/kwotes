import "dart:async";
import "dart:math";

import "package:algolia/algolia.dart";
import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_langdetect/flutter_langdetect.dart" as langdetect;
import "package:flutter_solidart/flutter_solidart.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/add_quote/quote_language_selector.dart";
import "package:kwotes/screens/add_quote/save_quote_button.dart";
import "package:kwotes/screens/add_quote/simple_add_quote_page.dart";
import "package:kwotes/screens/add_quote/snackbar_draft.dart";
import "package:kwotes/screens/add_quote/publish_button.dart";
import "package:kwotes/types/category.dart";
import "package:kwotes/types/enums/enum_draft_quote_operation.dart";
import "package:kwotes/types/intents/save_intent.dart";
import "package:kwotes/types/intents/submit_intent.dart";
import "package:kwotes/types/user/user_rights.dart";
import "package:loggy/loggy.dart";
import "package:text_wrap_auto_size/solution.dart";
import "package:text_wrap_auto_size/text_wrap_auto_size.dart";
import "package:verbal_expressions/verbal_expressions.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/add_quote/add_quote_app_bar_children.dart";
import "package:kwotes/screens/add_quote/add_quote_author_page.dart";
import "package:kwotes/screens/add_quote/add_quote_content.dart";
import "package:kwotes/screens/add_quote/add_quote_reference_page.dart";
import "package:kwotes/screens/add_quote/add_quote_topic_page.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/document_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/intents/index_intent.dart";
import "package:kwotes/types/intents/next_intent.dart";
import "package:kwotes/types/intents/previous_intent.dart";
import "package:kwotes/types/point_in_time.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/release.dart";
import "package:kwotes/types/topic.dart";
import "package:kwotes/types/user/user_firestore.dart";

class AddQuotePage extends StatefulWidget {
  /// Add a new quote or edit an existing quote page.
  const AddQuotePage({
    super.key,
    this.quoteId = "",
  });

  /// Unique id of the quote to edit.
  /// Empty if a new quote is being created.
  /// This parameter is useful for web browser url
  /// and to navigate to this specific page from a link (in case of edit).
  final String quoteId;

  @override
  State<AddQuotePage> createState() => _AddQuotePageState();
}

class _AddQuotePageState extends State<AddQuotePage> with UiLoggy {
  /// Show author metadata if true.
  bool _authorMetadataOpened = true;

  /// Show reference metadata if true.
  bool _referenceMetadataOpened = true;

  /// Show minimal builder if true (for users).
  /// Otherwise show complex add quote page (for creators).
  bool _showMinimalBuilder = true;

  /// Firestore quote document reference.
  DocumentReference? _docRef;

  /// Current quote's language selection.
  EnumLanguageSelection _languageSelection = EnumLanguageSelection.autoDetect;

  /// Page's state.
  EnumPageState _pageState = EnumPageState.idle;

  /// Total number of page views.
  final int _pageViewCount = 4;

  /// Previous page index.
  int _prevPageIndex = 0;

  /// Random author index.
  /// Used to display hint texts on author page.
  final int _randomAuthorIndex = Random().nextInt(10);

  /// Random reference index.
  /// Used to display hint texts on reference page.
  final int _randomReferenceIndex = Random().nextInt(10);

  /// Search result count limit (algolia).
  final int _searchLimit = 10;

  /// Used to request focus on the author job input.
  final FocusNode _authorJobFocusNode = FocusNode();

  /// Used to request focus on the author summary input.
  final FocusNode _authorSummaryFocusNode = FocusNode();

  /// Used to request focus on the content input.
  final FocusNode _contentFocusNode = FocusNode();

  /// Used to request focus on the author name input.
  final FocusNode _authorNameFocusNode = FocusNode();

  /// Used to deactivate focus on author name cancel button.
  final FocusNode _cancelAuthorNameFocusNode = FocusNode(
    canRequestFocus: false,
    skipTraversal: true,
    descendantsAreFocusable: false,
    descendantsAreTraversable: false,
  );

  /// Used to deactivate focus on reference name cancel button.
  final FocusNode _cancelReferenceNameFocusNode = FocusNode(
    canRequestFocus: false,
    skipTraversal: true,
    descendantsAreFocusable: false,
    descendantsAreTraversable: false,
  );

  /// Used to request focus on the reference name input.
  final FocusNode _referenceNameFocusNode = FocusNode();

  /// Used to request focus on the author summary input.
  final FocusNode _referenceSummaryFocusNode = FocusNode();

  /// Tooltip controller to confirm important action
  /// (e.g. delete quote).
  final JustTheController _tooltipController = JustTheController();

  /// Last used urls (from cloud).
  final List<String> _lastUsedAuthorUrls = ["website", "wikipedia", "youtube"];

  /// List of authors results for a specific search (algolia).
  final List<Author> _authorSearchResults = [];

  /// List of reference results for a specific search (algolia).
  final List<Reference> _referenceSearchResults = [];

  /// Categories list.
  final List<String> _categories = [];

  /// Shortcuts map.
  final Map<SingleActivator, Intent> _shortcuts = {
    const SingleActivator(
      LogicalKeyboardKey.keyS,
      meta: true,
    ): const SaveIntent(),
    const SingleActivator(
      LogicalKeyboardKey.keyP,
      meta: true,
    ): const SubmitIntent(),
    const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      meta: true,
      alt: true,
    ): const NextIntent(),
    const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      meta: true,
      alt: true,
    ): const PreviousIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit1,
      meta: true,
    ): const FirstIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit2,
      meta: true,
    ): const SecondIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit3,
      meta: true,
    ): const ThirdIndexIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit4,
      meta: true,
    ): const FourthIndexIntent(),
  };

  /// A controller for the page view.
  final PageController _pageViewController = PageController(initialPage: 0);

  /// Auto detected quote's language.
  String _autoDetectedLanguage = "";

  /// Content text controller.
  final TextEditingController _contentController = TextEditingController();

  /// Author's name text controller.
  final TextEditingController _authorNameController = TextEditingController();

  /// Author's job text controller.
  final TextEditingController _authorJobController = TextEditingController();

  /// Author's summary text controller.
  final TextEditingController _authorSummaryController =
      TextEditingController();

  /// Reference's name text controller.
  final TextEditingController _referenceNameController =
      TextEditingController();

  /// Reference's summary text controller.
  final TextEditingController _referenceSummaryController =
      TextEditingController();

  /// Used to temporarly show page title tooltip.
  /// Then hide after a delay.
  Timer? _timerPageTitle;

  /// Debounce timer to update quote.
  Timer? _timerUpdateQuote;

  /// Debounce timer to update suggestions.
  Timer? _timerUpdateSuggestions;

  final VerbalExpression _urlVerbExp = VerbalExpression()
    ..startOfLine()
    ..then("http")
    ..maybe("s")
    ..then("://")
    ..maybe("www")
    ..anythingBut(" ")
    ..endOfLine();

  @override
  void initState() {
    super.initState();
    _pageViewController.addListener(onPageViewChanged);
    initProps();
    fetchCategories();
    fetchQuoteDocument();

    _authorNameFocusNode.addListener(onAuthorNameFocusChanged);
    _authorJobFocusNode.addListener(onAuthorJobFocusChanged);
    _referenceNameFocusNode.addListener(onReferenceNameFocusChanged);
    _contentFocusNode.addListener(onContentFocusChanged);
    _authorSummaryFocusNode.addListener(onAuthorSummaryFocusChanged);
    _referenceSummaryFocusNode.addListener(onReferenceSummaryFocusChanged);
  }

  @override
  void dispose() {
    _docRef = null;
    _pageViewController.removeListener(onPageViewChanged);
    _pageViewController.dispose();
    _contentFocusNode.dispose();
    _timerUpdateQuote?.cancel();
    _timerPageTitle?.cancel();
    _timerUpdateSuggestions?.cancel();
    _contentController.dispose();
    _tooltipController.dispose();
    _authorNameFocusNode.dispose();
    _authorNameController.dispose();
    _authorJobController.dispose();
    _cancelAuthorNameFocusNode.dispose();
    _cancelReferenceNameFocusNode.dispose();
    _authorJobFocusNode.dispose();
    _referenceNameFocusNode.dispose();
    _referenceNameController.dispose();
    _referenceSummaryController.dispose();
    _authorSummaryController.dispose();
    _authorSummaryFocusNode.dispose();
    _referenceSummaryFocusNode.dispose();
    _authorSearchResults.clear();
    _referenceSearchResults.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    final bool isMobileSize =
        windowSize.width < Utils.measurements.mobileWidthTreshold ||
            windowSize.height < Utils.measurements.mobileHeightTreshold;

    final String textValue = _contentController.text.isNotEmpty
        ? _contentController.text
        : "quote.start_typing".tr();

    final Solution solution = TextWrapAutoSize.solution(
      Size(windowSize.width / 2, windowSize.height / 2),
      Text(
        textValue.trim(),
        style: Utils.calligraphy.body(
          textStyle: const TextStyle(
            fontSize: 52.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      minFontSize: 12.0,
      maxFontSize: isMobileSize ? 16.0 : null,
    );

    final Quote quote = NavigationStateHelper.quote;
    final bool isQuoteValid = quote.name.length > 3 && quote.topics.isNotEmpty;

    if (_pageState == EnumPageState.submittingQuote) {
      return LoadingView.scaffold(
        message: "${"quote.submit.ing".tr()}...",
      );
    }
    if (_pageState == EnumPageState.updatingQuote) {
      return LoadingView.scaffold(
        message: "${"quote.update.ing".tr()}...",
      );
    }
    if (_pageState == EnumPageState.validatingQuote) {
      return LoadingView.scaffold(
        message: "${"quote.validate.ing".tr()}...",
      );
    }

    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final String location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .uri
        .toString();

    final bool hasHistory = location != HomeLocation.route;

    final Signal<UserFirestore> userSignalFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final bool canManageQuotes =
        userSignalFirestore.value.rights.canManageQuotes;

    final SignalBuilder<UserFirestore> saveButton = SignalBuilder(
      signal: userSignalFirestore,
      builder: (
        BuildContext context,
        UserFirestore userFirestore,
        Widget? child,
      ) {
        return SaveQuoteButton(
          canManageQuotes: userFirestore.rights.canManageQuotes,
          isDark: isDark,
          isQuoteValid: isQuoteValid,
          isMobileSize: isMobileSize,
          onPressed: onSaveDraft,
          onLongPress: proposeQuote,
          quote: quote,
        );
      },
    );

    final SignalBuilder<UserFirestore> submitButton = SignalBuilder(
      signal: userSignalFirestore,
      builder: (
        BuildContext context,
        UserFirestore userFirestore,
        Widget? child,
      ) {
        if (quote is! DraftQuote) {
          return const SizedBox.shrink();
        }

        // final DraftQuote draft = quote as DraftQuote;
        if (quote.inValidation) {
          return const SizedBox.shrink();
        }

        return PublishQuoteButton(
          canManageQuotes: userFirestore.rights.canManageQuotes,
          isDark: isDark,
          isQuoteValid: isQuoteValid,
          isMobileSize: isMobileSize,
          onPressed: proposeQuote,
          quote: quote,
        );
      },
    );

    if (_showMinimalBuilder) {
      return SimpleAddQuotePage(
        authorNameController: _authorNameController,
        authorNameFocusNode: _authorNameFocusNode,
        cancelAuthorNameFocusNode: _cancelAuthorNameFocusNode,
        cancelReferenceNameFocusNode: _cancelReferenceNameFocusNode,
        canManageQuotes: canManageQuotes,
        contentFocusNode: _contentFocusNode,
        contentController: _contentController,
        isDark: isDark,
        isMobileSize: isMobileSize,
        languageSelector: QuoteLanguageSelector(
          languageSelection: _languageSelection,
          autoDetectedLanguage: _autoDetectedLanguage,
          isDark: isDark,
          foregroundColor: foregroundColor,
          onSelectLanguage: onSelectLanguage,
        ),
        foregroundColor: foregroundColor,
        hasHistory: hasHistory,
        onSelectLanguage: onSelectLanguage,
        onQuoteContentChanged: onQuoteContentChanged,
        onSaveShortcut: onSaveShortcut,
        onSubmitShortcut: onSubmitShortcut,
        shortcuts: _shortcuts,
        onAuthorNameChanged: onAuthorNameChanged,
        onReferenceNameChanged: onReferenceNameChanged,
        onShowComplexBuilder: onShowComplexBuilder,
        onSubmittedReferenceName: onSubmittedReferenceName,
        onTapCancelButtonAuthorName: onTapCancelButtonAuthorName,
        onTapCancelButtonContentName: onTapCancelButtonContent,
        onTapCancelButtonReferenceName: onTapCancelButtonReferenceName,
        randomAuthorInt: _randomAuthorIndex,
        randomReferenceInt: _randomReferenceIndex,
        referenceNameController: _referenceNameController,
        referenceNameFocusNode: _referenceNameFocusNode,
        saveButton: saveButton,
        submitButton: submitButton,
        windowSize: windowSize,
      );
    }

    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: {
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: onSaveShortcut,
          ),
          SubmitIntent: CallbackAction<SubmitIntent>(
            onInvoke: onSubmitShortcut,
          ),
          NextIntent: CallbackAction<NextIntent>(
            onInvoke: onNextShortcut,
          ),
          PreviousIntent: CallbackAction<PreviousIntent>(
            onInvoke: onPreviousShortcut,
          ),
          FirstIndexIntent: CallbackAction<FirstIndexIntent>(
            onInvoke: onFirstIndexShortcut,
          ),
          SecondIndexIntent: CallbackAction<SecondIndexIntent>(
            onInvoke: onSecondIndexShortcut,
          ),
          ThirdIndexIntent: CallbackAction<ThirdIndexIntent>(
            onInvoke: onThirdIndexShortcut,
          ),
          FourthIndexIntent: CallbackAction<FourthIndexIntent>(
            onInvoke: onFourthIndexShortcut,
          ),
        },
        child: SafeArea(
          child: DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: Utils.graphic.addQuoteAppBar(
                context,
                hasHistory: hasHistory,
                isMobileSize: isMobileSize,
                foregroundColor: foregroundColor,
                onTapAppIcon: () => context.beamToNamed(HomeLocation.route),
              ),
              body: TabBarView(
                children: [
                  AddQuoteContent(
                    languageSelector: QuoteLanguageSelector(
                      languageSelection: _languageSelection,
                      autoDetectedLanguage: _autoDetectedLanguage,
                      isDark: isDark,
                      foregroundColor: foregroundColor,
                      onSelectLanguage: onSelectLanguage,
                    ),
                    tooltipController: _tooltipController,
                    contentController: _contentController,
                    contentFocusNode: _contentFocusNode,
                    onContentChanged: onQuoteContentChanged,
                    isDark: isDark,
                    isMobileSize: isMobileSize,
                    onTapCancelButton: onTapCancelButtonContent,
                    onDeleteQuote: onDeleteDraft,
                    onShowMinimalBuilder: onShowMinimalBuilder,
                    saveButton: saveButton,
                    solution: solution,
                  ),
                  AddQuoteTopicPage(
                    appBarRightChildren: AddQuoteAppBarChildren.getChildren(
                      context,
                      clearAllTooltip: "quote.clear.topics".tr(),
                      onClearAll: onClearTopic,
                      onDeleteQuote: onDeleteDraft,
                      tooltipController: _tooltipController,
                    ),
                    categories: _categories,
                    isDark: isDark,
                    isMobileSize: isMobileSize,
                    topics: Constants.colors.topics,
                    onSelected: onTopicSelected,
                    onToggleCategory: onToggleCategory,
                    onClearTopic: onClearTopic,
                    saveButton: saveButton,
                  ),
                  AddQuoteAuthorPage(
                    appBarRightChildren: AddQuoteAppBarChildren.getChildren(
                      context,
                      clearAllTooltip: "quote.clear.author".tr(),
                      onClearAll: onClearAuthorData,
                      onDeleteQuote: onDeleteDraft,
                      tooltipController: _tooltipController,
                    ),
                    author: NavigationStateHelper.quote.author,
                    authorSuggestions: _authorSearchResults,
                    canManageAuthors: canManageQuotes,
                    isDark: isDark,
                    isMobileSize: isMobileSize,
                    jobFocusNode: _authorJobFocusNode,
                    lastUsedUrls: _lastUsedAuthorUrls,
                    summaryFocusNode: _authorSummaryFocusNode,
                    metadataOpened: _authorMetadataOpened,
                    nameFocusNode: _authorNameFocusNode,
                    onTapCancelButtonSummary: onTapCancelButtonAuthorSummary,
                    onNameChanged: onAuthorNameChanged,
                    onJobChanged: onAuthorJobChanged,
                    onProfilePictureChanged: onAuthorPictureUrlChanged,
                    onSummaryChanged: onAuthorSummaryChanged,
                    onTapAuthorSuggestion: onTapAuthorSuggestion,
                    onTapBirthDate: onTapBirthDate,
                    onTapCancelButtonName: onTapCancelButtonAuthorName,
                    onTapCancelButtonJob: onTapCancelButtonAuthorJob,
                    onTapDeathDate: onTapDeathDate,
                    onTapShowSuggestionsAsList: openAuthorListSuggestions,
                    onToggleMetadata: onToggleAuthorMetadata,
                    onToggleIsFictional: onToggleIsFictional,
                    onToggleNagativeBirthDate: onToggleNagativeBirthDate,
                    onToggleNagativeDeathDate: onToggleNagativeDeathDate,
                    onUrlChanged: onAuthorUrlChanged,
                    randomAuthorInt: _randomAuthorIndex,
                    nameController: _authorNameController,
                    jobController: _authorJobController,
                    summaryController: _authorSummaryController,
                  ),
                  AddQuoteReferencePage(
                    appBarRightChildren: AddQuoteAppBarChildren.getChildren(
                      context,
                      clearAllTooltip: "quote.clear.reference".tr(),
                      onClearAll: onClearReferenceData,
                      onDeleteQuote: onDeleteDraft,
                      tooltipController: _tooltipController,
                    ),
                    canManageReferences: canManageQuotes,
                    isDark: isDark,
                    isMobileSize: isMobileSize,
                    lastUsedUrls: _lastUsedAuthorUrls,
                    metadataOpened: _referenceMetadataOpened,
                    nameController: _referenceNameController,
                    nameFocusNode: _referenceNameFocusNode,
                    onNameChanged: onReferenceNameChanged,
                    onPictureUrlChanged: onReferencePictureUrlChanged,
                    onPrimaryGenreChanged: onPrimaryGenreChanged,
                    onSecondaryGenreChanged: onSecondaryGenreChanged,
                    onSummaryChanged: onReferenceSummaryChanged,
                    onTapCancelButtonName: onTapCancelButtonReferenceName,
                    onTapCancelButtonSummary: onTapCancelButtonReferenceSummary,
                    onTapSuggestion: onTapReferenceSuggestion,
                    onTapReleaseDate: onTapReleaseDate,
                    onTapShowSuggestionsAsList: openReferenceListSuggestions,
                    onToggleMetadata: onToggleReferenceMetadata,
                    onToggleNagativeReleaseDate: onToggleNagativeReleaseDate,
                    onUrlChanged: onReferenceUrlChanged,
                    randomReferenceInt: _randomReferenceIndex,
                    reference: NavigationStateHelper.quote.reference,
                    referenceSuggestions: _referenceSearchResults,
                    summaryFocusNode: _referenceSummaryFocusNode,
                    summaryController: _referenceSummaryController,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fetch categories from firestore.
  Future<void> fetchCategories() async {
    final QuerySnapMap snapshot =
        await FirebaseFirestore.instance.collection("categories").get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    _categories.clear();

    for (final QueryDocSnapMap doc in snapshot.docs) {
      final category = Category.fromMap(doc.data());
      _categories.add(category.name);
    }

    setState(() {});
  }

  /// Fetch draft quote document in firestore.
  void fetchDraftQuote(DraftQuote quote) async {
    try {
      final DocumentMap query = getDraftQuoteQuery(quote);
      final DocumentSnapshotMap docSnap = await query.get();

      if (!docSnap.exists) {
        loggy.error("Failed to fetch draft.");
        if (!mounted) {
          return;
        }

        Utils.graphic.showSnackbar(
          context,
          message: "quote.fetch.draft.failed".tr(),
        );
        return;
      }

      setState(() {
        _docRef = docSnap.reference;
        populateFields(quote);
      });

      updateAuthorSuggestions(quote.author.name);
      updateReferenceSuggestions(quote.reference.name);
    } catch (error) {
      loggy.error(error);
    }
  }

  void populateFields(Quote quote) {
    _contentController.text = quote.name;
    _authorNameController.text = quote.author.name;
    _authorJobController.text = quote.author.job;
    _authorSummaryController.text = quote.author.summary;
    _referenceNameController.text = quote.reference.name;
    _referenceSummaryController.text = quote.reference.summary;

    initAutoLang();
    updateAuthorSuggestions(quote.author.name);
    updateReferenceSuggestions(quote.reference.name);

    _contentController.selection = TextSelection.fromPosition(
      TextPosition(
        affinity: TextAffinity.downstream,
        offset: quote.name.length,
      ),
    );
  }

  /// Fetch quote document in firestore.
  void fetchQuoteDocument() async {
    final Quote quote = NavigationStateHelper.quote;

    if (widget.quoteId.isNotEmpty && quote.id != widget.quoteId) {
      fetchQuoteFromUrl(widget.quoteId);
      return;
    }

    if (quote.id.isEmpty) {
      tryCreateDraft();
      return;
    }

    if (quote is DraftQuote) {
      fetchDraftQuote(quote);
      return;
    }

    fetchPublishedQuote(quote);
  }

  /// Fetch published quote document in firestore.
  void fetchPublishedQuote(Quote quote) async {
    try {
      final DocumentSnapshotMap docSnap = await FirebaseFirestore.instance
          .collection("quotes")
          .doc(quote.id)
          .get();

      if (!docSnap.exists) {
        loggy.error("Failed to fetch quote.");
        if (!mounted) {
          return;
        }

        Utils.graphic.showSnackbar(
          context,
          message: "quote.fetch.failed".tr(),
        );
        return;
      }

      setState(() {
        _contentController.text = quote.name;
        _docRef = docSnap.reference;
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(
            affinity: TextAffinity.downstream,
            offset: quote.name.length,
          ),
        );

        _authorNameController.text = quote.author.name;
        _authorSummaryController.text = quote.author.summary;
        _referenceNameController.text = quote.reference.name;
        _referenceSummaryController.text = quote.reference.summary;
      });
    } catch (error) {
      loggy.error(error);
    }
  }

  /// Fetch quote document from url.
  /// Because we have only the quote's id,
  /// we need to try to fetch it from different collections.
  void fetchQuoteFromUrl(String quoteId) async {
    final Quote? publishedQuote = await tryFetchPubQuoteFromUrl(quoteId);
    if (publishedQuote != null) {
      NavigationStateHelper.quote = publishedQuote;
      return;
    }

    final DraftQuote? publicDraft = await tryFetchPubDraftFromUrl(quoteId);
    if (publicDraft != null) {
      NavigationStateHelper.quote = publicDraft;
      return;
    }

    final DraftQuote? privateDraft = await tryFetchPrivateDraftFromUrl(
      quoteId,
    );
    if (privateDraft != null) {
      NavigationStateHelper.quote = privateDraft;
      return;
    }
  }

  /// Get active dot color.
  Color getActiveDotColor() {
    if (!_pageViewController.hasClients) {
      return Constants.colors.foregroundPalette.first;
    }

    return Constants.colors.foregroundPalette
        .elementAt(_pageViewController.page?.toInt() ?? 0);
  }

  DocumentMap getDraftQuoteQuery(DraftQuote quote) {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (quote.inValidation) {
      return FirebaseFirestore.instance.collection("drafts").doc(quote.id);
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userFirestoreSignal.value.id)
        .collection("drafts")
        .doc(quote.id);
  }

  String getPageTitleTooltip() {
    if (_pageViewController.positions.isEmpty) {
      return "";
    }

    return "quote.add.page.${_pageViewController.page?.toInt()}".tr();
  }

  /// Check if the quote's required properties are valid.
  bool hasGoodFormatting(Quote quote) {
    if (quote.name.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.name.empty".tr(),
      );

      return false;
    }

    if (quote.name.length < 3) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.name.minimum_length".tr(),
      );

      return false;
    }

    // NOTE: We now allow user to create quotes without topics.
    // Validators will add the appropriate topics.
    // -------------------------------------------------------
    // if (quote.topics.isEmpty) {
    //   Utils.graphic.showSnackbar(
    //     context,
    //     message: "quote.error.topic.empty".tr(),
    //   );

    //   return false;
    // }

    return true;
  }

  /// Initialize props.
  void initProps() async {
    _languageSelection = await Utils.vault.getLanguageSelection();
    _authorMetadataOpened = await Utils.vault.getAddAuthorMetadataOpened();
    _referenceMetadataOpened =
        await Utils.vault.getAddReferenceMetadataOpened();
  }

  /// Callback fired when author's name has changed.
  void onAuthorNameChanged(String name) {
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      author: NavigationStateHelper.quote.author.copyWith(
        id: "",
        name: name,
      ),
    );

    updateQuoteDoc();
    updateAuthorSuggestions(name);
  }

  /// Callback fired when author's job has changed.
  void onAuthorJobChanged(String job) {
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      author: NavigationStateHelper.quote.author.copyWith(
        job: job,
      ),
    );

    updateQuoteDoc();
  }

  /// Callback fired when url input for profile picture has changed.
  void onAuthorPictureUrlChanged(String url) {
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      author: NavigationStateHelper.quote.author.copyWith(
        urls: NavigationStateHelper.quote.author.urls.copyWith(
          image: url,
        ),
      ),
    );

    updateQuoteDoc();

    if (_urlVerbExp.hasMatch(url)) {
      setState(() {});
    }
  }

  /// Callback fired when author's summary has changed.
  void onAuthorSummaryChanged(String summary) {
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      author: NavigationStateHelper.quote.author.copyWith(
        summary: summary,
      ),
    );

    updateQuoteDoc();
  }

  /// Callback fired when an url input has changed for author.
  void onAuthorUrlChanged(String key, String value) {
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      author: NavigationStateHelper.quote.author.copyWith(
        urls: NavigationStateHelper.quote.author.urls.copyWithKey(
          key: key,
          value: value,
        ),
      ),
    );

    updateQuoteDoc();
  }

  /// Callback fired to clear author data.
  void onClearAuthorData() {
    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        author: Author.empty(),
      );
    });

    _authorSummaryController.clear();
    _authorNameController.clear();

    updateQuoteDoc();
  }

  /// Callback fired to clear quote's content.
  void onClearQuoteContent() {
    setState(() {
      _contentController.text = "";
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        name: "",
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired to clear reference data and inputs.
  void onClearReferenceData() {
    setState(() {
      _referenceNameController.clear();
      _referenceSummaryController.clear();
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        reference: Reference.empty(),
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired to clear selected topics.
  void onClearTopic() {
    setState(() {
      NavigationStateHelper.quote.topics.clear();
    });

    updateQuoteDoc();
  }

  /// Callback fired to delete draft.
  void onDeleteDraft() {
    _tooltipController.hideTooltip();

    _docRef?.delete();

    if (context.canBeamBack) {
      context.beamBack();
      return;
    }

    context.beamToNamed(DashboardLocation.route);
  }

  /// Callback fired when dot indicator is tapped.
  void onDotIndicatorTapped(int index) {
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  /// Callback fired to navigate to the 1st page.
  Object? onFirstIndexShortcut(FirstIndexIntent intent) {
    return _pageViewController.animateToPage(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  /// Callback fired to navigate to the 4rd page.
  Object? onFourthIndexShortcut(FourthIndexIntent intent) {
    return _pageViewController.animateToPage(
      3,
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  /// Navigate to the next page view when shortcut pressed.
  Object? onNextShortcut(NextIntent intent) {
    final double page = _pageViewController.page ?? 0.0;
    if (page >= _pageViewCount - 1) {
      return _pageViewController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.decelerate,
      );
    }

    return _pageViewController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  /// Navigate to the previous page view when shortcut pressed.
  Object? onPreviousShortcut(PreviousIntent intent) {
    final double page = _pageViewController.page ?? 0.0;
    if (page <= 0.0) {
      return _pageViewController.animateToPage(
        _pageViewCount - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.decelerate,
      );
    }

    return _pageViewController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  /// Callback fired to save quote.
  Object? onSaveShortcut(SaveIntent intent) {
    onSaveDraft();
    return null;
  }

  /// Callback fired to submit quote.
  Object? onSubmitShortcut(SubmitIntent intent) {
    onSubmitQuote();
    return null;
  }

  /// Callback fired when main genre has changed.
  void onPrimaryGenreChanged(String mainGenre) {
    final Reference reference = NavigationStateHelper.quote.reference;
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      reference: reference.copyWith(
        type: reference.type.copyWith(
          primary: mainGenre,
        ),
      ),
    );

    updateQuoteDoc();
  }

  void initAutoLang() {
    final bool isLangAutoDetect =
        _languageSelection == EnumLanguageSelection.autoDetect;

    if (!isLangAutoDetect) return;
    _autoDetectedLanguage = langdetect.detect(_contentController.text);
  }

  /// Callback fired when quote's content has changed.
  void onQuoteContentChanged(String content) {
    final bool isLangAutoDetect =
        _languageSelection == EnumLanguageSelection.autoDetect;

    if (content.length >= 3 && isLangAutoDetect) {
      _autoDetectedLanguage = langdetect.detect(content);

      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        language: _autoDetectedLanguage,
        name: content,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
      updateQuoteDoc();
      return;
    }

    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        name: content,
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired to navigate to the next page.
  void onNextPage() {
    if (_pageViewController.page == (_pageViewCount - 1.0)) {
      _pageViewController.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.ease,
      );
      return;
    }

    _pageViewController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  /// Show the page title tooltip when page changes.
  void onPageViewChanged() {
    final int? currentPageIndex = _pageViewController.page?.toInt();
    if (currentPageIndex == _prevPageIndex) {
      return;
    }

    setState(() {
      _prevPageIndex = currentPageIndex ?? -1;
    });

    final bool isMobilePlatform = Utils.graphic.isMobile();
    if (isMobilePlatform) {
      return;
    }

    if (currentPageIndex == 2) {
      _authorNameFocusNode.requestFocus();
    }

    if (currentPageIndex == 3) {
      _referenceNameFocusNode.requestFocus();
    }
  }

  /// Open author list suggestions as list.
  void openAuthorListSuggestions() {
    final List<Color> darkPalette = Constants.colors.darkerForegroundPalette;

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
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            final Author author = _authorSearchResults[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextButton(
                onPressed: () {
                  onTapAuthorSuggestion.call(author);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 54.0,
                            height: 1.0,
                            fontWeight: FontWeight.w300,
                            color: darkPalette[index % darkPalette.length],
                          ),
                        ),
                      ),
                      Text(
                        author.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          shrinkWrap: true,
          itemCount: _authorSearchResults.length,
        );
      },
    );
  }

  /// Open reference list suggestions as list.
  void openReferenceListSuggestions() {
    final List<Color> darkPalette = Constants.colors.darkerForegroundPalette;

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
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            final Reference reference = _referenceSearchResults[index];
            return TextButton(
              onPressed: () {
                onTapReferenceSuggestion.call(reference);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reference.name,
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 54.0,
                          fontWeight: FontWeight.w300,
                          color: darkPalette[index % darkPalette.length],
                        ),
                      ),
                    ),
                    Text(
                      reference.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          shrinkWrap: true,
          itemCount: _referenceSearchResults.length,
        );
      },
    );
  }

  /// Callback fired to navigate to the previous page.
  void onPreviousPage() {
    if (_pageViewController.page == 0.0) {
      _pageViewController.animateToPage(
        _pageViewCount - 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.ease,
      );
      return;
    }

    _pageViewController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  /// Callback fired when reference's name has changed.
  void onReferenceNameChanged(String name) {
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      reference: NavigationStateHelper.quote.reference.copyWith(
        name: name,
      ),
    );

    updateQuoteDoc();
    updateReferenceSuggestions(name);
  }

  /// Callback fired when reference's picture url has changed.
  void onReferencePictureUrlChanged(String url) {
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      reference: NavigationStateHelper.quote.reference.copyWith(
        urls: NavigationStateHelper.quote.reference.urls.copyWith(
          image: url,
        ),
      ),
    );

    updateQuoteDoc();

    if (_urlVerbExp.hasMatch(url)) {
      setState(() {});
    }
  }

  /// Callback fired when reference's summary has changed.
  void onReferenceSummaryChanged(String summary) {
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      reference: NavigationStateHelper.quote.reference.copyWith(
        summary: summary,
      ),
    );

    updateQuoteDoc();
  }

  /// Callback fired when one of the reference's urls (e.g. wikipedia)
  /// has changed.
  void onReferenceUrlChanged(String key, String value) {
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      reference: NavigationStateHelper.quote.reference.copyWith(
        urls: NavigationStateHelper.quote.reference.urls.copyWithKey(
          key: key,
          value: value,
        ),
      ),
    );

    updateQuoteDoc();
  }

  void showSavedDraftTip() {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final SnackBarBehavior behavior =
        isMobileSize ? SnackBarBehavior.fixed : SnackBarBehavior.floating;

    bool isInValidation = false;
    if (NavigationStateHelper.quote is DraftQuote) {
      final DraftQuote draft = NavigationStateHelper.quote as DraftQuote;
      if (draft.inValidation) {
        isInValidation = true;
      }
    }

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final String userId = userFirestoreSignal.value.id;
    final Quote quote = NavigationStateHelper.quote;

    final bool hideSubmitButton = userId.isEmpty ||
        quote.id.isEmpty ||
        quote.name.isEmpty ||
        quote.name.length < 3 ||
        quote.topics.isEmpty;

    Utils.graphic.showSnackbarWithCustomText(
      context,
      behavior: behavior,
      duration: const Duration(seconds: 6),
      showCloseIcon: !isMobileSize,
      text: SnackbarDraft(
        quote: quote,
        isInValidation: isInValidation,
        isMobileSize: isMobileSize,
        userId: userId,
        hideSubmitButton: hideSubmitButton,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
        side: BorderSide(color: Colors.green.shade100, width: 4.0),
      ),
    );
  }

  /// Callback fired to (phantom) save draft.
  /// This method does nothing really useful except notifying the user.
  /// Shows a "propose" button to consecutively send the draft
  /// to the global collection.
  void onSaveDraft() async {
    final bool showTip = await Utils.vault.getShowSavedDraftTip();
    if (showTip) {
      showSavedDraftTip();
    }

    navigateWhenFinished();
  }

  void navigateWhenFinished() {
    Beamer.of(context).beamToNamed(DashboardContentLocation.myQuotesRoute);
  }

  /// Callback fired when secondary genre has changed.
  void onSecondaryGenreChanged(String subGenre) {
    final Reference reference = NavigationStateHelper.quote.reference;
    NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
      reference: reference.copyWith(
        type: reference.type.copyWith(
          secondary: subGenre,
        ),
      ),
    );

    updateQuoteDoc();
  }

  /// Callback fired to navigate to the 2nd page.
  Object? onSecondIndexShortcut(SecondIndexIntent intent) {
    return _pageViewController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  void onSelectLanguage(EnumLanguageSelection languageSelection) {
    String language = languageSelection.name;
    Utils.vault.setQuoteLanguageSelection(languageSelection);

    if (languageSelection == EnumLanguageSelection.autoDetect) {
      language = langdetect.detect(NavigationStateHelper.quote.name);
      _autoDetectedLanguage = language;
    } else {
      _autoDetectedLanguage = "";
    }

    setState(() {
      _languageSelection = languageSelection;
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        language: language,
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired when we try to submit the quote to validation.
  void onSubmitQuote() {
    final Quote quote = NavigationStateHelper.quote;

    if (quote is! DraftQuote) {
      updateQuote();
      return;
    }

    if (quote.inValidation) {
      validateDraft();
      return;
    }

    if (!quote.inValidation) {
      proposeQuote();
      return;
    }
  }

  /// Callback fired when an author suggestion is tapped.
  void onTapAuthorSuggestion(Author author) {
    if (author.id == NavigationStateHelper.quote.author.id) {
      onClearAuthorData();
      return;
    }

    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        author: author,
      );

      _authorNameController.text = author.name;
      _authorJobController.text = author.job;
      _authorSummaryController.text = author.summary;
    });

    updateQuoteDoc();
  }

  /// Callback fired when birth date chip is tapped.
  /// Shows a date picker.
  void onTapBirthDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: DateTime.now(),
      firstDate: DateTime(0),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    final PointInTime authorBirth = NavigationStateHelper.quote.author.birth;

    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        author: NavigationStateHelper.quote.author.copyWith(
          birth: authorBirth.copyWith(
            date: pickedDate,
            isDateEmpty: false,
          ),
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired when death date chip is tapped.
  /// Shows a date picker.
  void onTapDeathDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: DateTime.now(),
      firstDate: DateTime(0),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    final PointInTime authorDeath = NavigationStateHelper.quote.author.death;

    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        author: NavigationStateHelper.quote.author.copyWith(
          death: authorDeath.copyWith(
            date: pickedDate,
            isDateEmpty: false,
          ),
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired when a reference suggestion is tapped.
  void onTapReferenceSuggestion(Reference reference) {
    if (reference.id == NavigationStateHelper.quote.reference.id) {
      onClearReferenceData();
      return;
    }

    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        reference: reference,
      );

      _referenceNameController.text = reference.name;
      _referenceSummaryController.text = reference.summary;
    });

    updateQuoteDoc();
  }

  /// Callback fired when release date chip is tapped.
  void onTapReleaseDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: DateTime.now(),
      firstDate: DateTime(0),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    final Reference reference = NavigationStateHelper.quote.reference;

    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        reference: reference.copyWith(
          release: Release(
            original: pickedDate,
            beforeCommonEra: reference.release.beforeCommonEra,
            isEmpty: false,
          ),
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired to navigate to the 3rd page.
  Object? onThirdIndexShortcut(ThirdIndexIntent intent) {
    return _pageViewController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  /// Author job input focus change callback.
  void onAuthorJobFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Focus change callback.
  void onAuthorNameFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Author summary input focus change callback.
  void onAuthorSummaryFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Quote's content input focus change callback.
  void onContentFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Focus change callback.
  void onReferenceNameFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Reference summary input focus change callback.
  void onReferenceSummaryFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Callback fired when cancel button is tapped on author's name input.
  void onTapCancelButtonAuthorName() {
    _authorNameFocusNode.unfocus();
  }

  /// Callback fired when cancel button is tapped on author's job input.
  void onTapCancelButtonAuthorJob() {
    _authorJobFocusNode.unfocus();
  }

  /// Callback fired when cancel button is tapped on author's summary input.
  void onTapCancelButtonAuthorSummary() {
    _authorSummaryFocusNode.unfocus();
  }

  /// Callback fired when cancel button is tapped on quote's content input.
  void onTapCancelButtonContent() {
    _contentFocusNode.unfocus();
  }

  /// Callback fired when cancel button is tapped on reference name input.
  void onTapCancelButtonReferenceName() {
    _referenceNameFocusNode.unfocus();
  }

  /// Callback fired when cancel button is tapped on referece summary input.
  void onTapCancelButtonReferenceSummary() {
    _referenceSummaryFocusNode.unfocus();
  }

  /// Callback fired to toggle author metadata widget size.
  void onToggleAuthorMetadata() {
    Utils.vault.setAddAuthorMetadataOpened(!_authorMetadataOpened);
    setState(() => _authorMetadataOpened = !_authorMetadataOpened);
  }

  /// Callback fired when fictional value has changed.
  void onToggleIsFictional() {
    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        author: NavigationStateHelper.quote.author.copyWith(
          isFictional: !NavigationStateHelper.quote.author.isFictional,
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired when nagative birth date chip is tapped.
  void onToggleNagativeBirthDate() {
    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
          author: NavigationStateHelper.quote.author.copyWith(
        birth: NavigationStateHelper.quote.author.birth.copyWith(
          beforeCommonEra:
              !NavigationStateHelper.quote.author.birth.beforeCommonEra,
        ),
      ));
    });

    updateQuoteDoc();
  }

  /// Callback fired when nagative death date chip is tapped.
  void onToggleNagativeDeathDate() {
    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        author: NavigationStateHelper.quote.author.copyWith(
          death: NavigationStateHelper.quote.author.death.copyWith(
            beforeCommonEra:
                !NavigationStateHelper.quote.author.death.beforeCommonEra,
          ),
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Switch between before and after common era.
  void onToggleNagativeReleaseDate() {
    setState(() {
      NavigationStateHelper.quote = NavigationStateHelper.quote.copyWith(
        reference: NavigationStateHelper.quote.reference.copyWith(
          release: NavigationStateHelper.quote.reference.release.copyWith(
            beforeCommonEra:
                !NavigationStateHelper.quote.reference.release.beforeCommonEra,
          ),
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired to toggle author metadata widget size.
  void onToggleReferenceMetadata() {
    Utils.vault.setAddReferenceMetadataOpened(!_referenceMetadataOpened);
    setState(() => _referenceMetadataOpened = !_referenceMetadataOpened);
  }

  /// Callback fired when a topic is tapped.
  void onTopicSelected(Topic topic, bool selected) {
    if (selected) {
      setState(() {
        NavigationStateHelper.quote.topics.add(topic.name);
      });

      updateQuoteDoc();
      return;
    }

    setState(() {
      NavigationStateHelper.quote.topics.remove(topic.name);
    });

    updateQuoteDoc();
  }

  /// Propose a new quote in global drafts collection.
  void proposeQuote() async {
    final Quote quote = NavigationStateHelper.quote;
    if (!hasGoodFormatting(quote)) {
      return;
    }

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestoreSignal.value.id.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.user.unauthenticated".tr(),
      );
      return;
    }

    setState(() => _pageState = EnumPageState.submittingQuote);
    final String userId = userFirestoreSignal.value.id;

    try {
      final Map<String, dynamic> map = quote.toMap(
        userId: userId,
        operation: EnumQuoteOperation.create,
      );

      await FirebaseFirestore.instance.collection("drafts").add(map);

      /// Delete user's draft
      /// because we copied it to the global drafts collection.
      _docRef?.delete();

      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: "quote.submit.success".tr(),
      );

      navigateWhenFinished();
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);
      Utils.graphic.showSnackbar(
        context,
        message: "quote.submit.failed".tr(),
      );
    }
  }

  /// Save existing draft in global drafts collection.
  void saveExistingDraftInValidation() async {
    final DraftQuote quote = NavigationStateHelper.quote as DraftQuote;
    if (!hasGoodFormatting(quote)) {
      return;
    }

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestoreSignal.value.id.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.user.unauthenticated".tr(),
      );
      return;
    }

    setState(() => _pageState = EnumPageState.submittingQuote);

    try {
      await _docRef
          ?.update((NavigationStateHelper.quote as DraftQuote).toMap());

      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: "quote.udpate.success".tr(),
      );

      navigateWhenFinished();
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);

      Utils.graphic.showSnackbar(
        context,
        message: "quote.udpate.failed".tr(),
      );
    }
  }

  /// Try creating a draft if we're not editing a quote.
  void tryCreateDraft() async {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestoreSignal.value.id.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "signin.again".tr(),
      );
      return;
    }

    final Quote navigationQuote = NavigationStateHelper.quote;

    try {
      final QuerySnapMap existingEmptyDrafts = await FirebaseFirestore.instance
          .collection("users")
          .doc(userFirestoreSignal.value.id)
          .collection("drafts")
          .where("name", isEqualTo: "")
          .get();

      if (existingEmptyDrafts.size > 0) {
        final QueryDocSnapMap firstDraftDoc = existingEmptyDrafts.docs.first;
        _docRef = firstDraftDoc.reference;

        final Json emptyDraftMap = firstDraftDoc.data();
        emptyDraftMap["id"] = firstDraftDoc.id;

        // From "copy from" action.
        if (navigationQuote.id.isEmpty && navigationQuote.name.isNotEmpty) {
          emptyDraftMap.addAll(
            navigationQuote.toMap(
              operation: EnumQuoteOperation.create,
              userId: userFirestoreSignal.value.id,
            ),
          );
        }

        final DraftQuote newDraft = DraftQuote.fromMap(emptyDraftMap);
        setState(() => NavigationStateHelper.quote = newDraft);
        populateFields(newDraft);
        return;
      }

      final DocumentMap newDraftDocRef = await FirebaseFirestore.instance
          .collection("users")
          .doc(userFirestoreSignal.value.id)
          .collection("drafts")
          .add(
            navigationQuote.toMap(
              operation: EnumQuoteOperation.create,
              userId: userFirestoreSignal.value.id,
            ),
          );

      final DocumentSnapshotMap newDraftDoc = await newDraftDocRef.get();
      final Json? draftMap = newDraftDoc.data();
      _docRef = newDraftDocRef;

      if (!newDraftDoc.exists || draftMap == null) {
        loggy.error("Failed to create draft.");
        if (!mounted) return;

        Utils.graphic.showSnackbar(
          context,
          message: "quote.add.draft.failed".tr(),
        );
        return;
      }

      draftMap["id"] = newDraftDoc.id;
      final DraftQuote newDraft = DraftQuote.fromMap(draftMap);
      setState(() => NavigationStateHelper.quote = newDraft);
      populateFields(newDraft);
    } catch (error) {
      loggy.error(error);
    }
  }

  /// Try to fetch private draft quote document from a quote's id.
  Future<DraftQuote?> tryFetchPrivateDraftFromUrl(String quoteId) async {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    try {
      final DocumentSnapshotMap docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userFirestoreSignal.value.id)
          .collection("drafts")
          .doc(quoteId)
          .get();

      if (!docSnap.exists) {
        return null;
      }

      _docRef = docSnap.reference;
      return DraftQuote.fromMap(docSnap.data());
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  /// Try to fetch draft quote document from a quote's id.
  Future<DraftQuote?> tryFetchPubDraftFromUrl(String quoteId) async {
    try {
      final DocumentSnapshotMap docSnap = await FirebaseFirestore.instance
          .collection("drafts")
          .doc(quoteId)
          .get();

      if (!docSnap.exists) {
        return null;
      }

      _docRef = docSnap.reference;
      return DraftQuote.fromMap(docSnap.data());
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  /// Try to fetch published quote document from a quote's id.
  Future<Quote?> tryFetchPubQuoteFromUrl(String quoteId) async {
    try {
      final DocumentSnapshotMap docSnap = await FirebaseFirestore.instance
          .collection("quotes")
          .doc(quoteId)
          .get();

      if (!docSnap.exists) {
        return null;
      }

      _docRef = docSnap.reference;
      return Quote.fromMap(docSnap.data());
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  /// Find authors according to the passed text.
  void trySearchAuthors(String text) async {
    _authorSearchResults.clear();

    try {
      final AlgoliaQuery query = Utils.search.algolia
          .index("authors")
          .query(text)
          .setHitsPerPage(_searchLimit)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() {
          _pageState = EnumPageState.idle;
        });
        return;
      }

      for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
        final Json data = hit.data;
        data["id"] = hit.objectID;

        final Author author = Author.fromMap(data);
        _authorSearchResults.add(author);
      }

      setState(() {});
    } catch (error) {
      loggy.error(error.toString());
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Find authors according to the passed text.
  void trySearchReferences(String text) async {
    _referenceSearchResults.clear();

    try {
      final AlgoliaQuery query = Utils.search.algolia
          .index("references")
          .query(text)
          .setHitsPerPage(_searchLimit)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() {
          _pageState = EnumPageState.idle;
        });
        return;
      }

      for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
        final Json data = hit.data;
        data["id"] = hit.objectID;

        final Reference reference = Reference.fromMap(data);
        _referenceSearchResults.add(reference);
      }

      setState(() {});
    } catch (error) {
      loggy.error(error.toString());
      if (!mounted) return;
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Update quote document in firestore.
  void updateQuoteDoc() {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    _timerUpdateQuote?.cancel();
    _timerUpdateQuote = Timer(const Duration(milliseconds: 1000), () {
      _docRef?.update(
        NavigationStateHelper.quote.toMap(
          userId: userFirestoreSignal.value.id,
        ),
      );
    });
  }

  /// Immediately update quote then navigate back.
  void updateQuote() async {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final UserRights rights = userFirestoreSignal.value.rights;
    if (!rights.canManageQuotes) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.user.unauthorized".tr(),
      );
      return;
    }

    setState(() => _pageState = EnumPageState.updatingQuote);
    await _docRef?.update(NavigationStateHelper.quote.toMap());

    if (!mounted) return;
    navigateWhenFinished();
  }

  /// Update search suggestions.
  void updateAuthorSuggestions(String text) {
    _timerUpdateSuggestions?.cancel();

    if (text.isEmpty) {
      setState(() {
        _authorSearchResults.clear();
      });
      return;
    }

    _timerUpdateSuggestions = Timer(
      const Duration(milliseconds: 1000),
      () => trySearchAuthors(text),
    );
  }

  /// Update search suggestions.
  void updateReferenceSuggestions(String text) {
    _timerUpdateSuggestions?.cancel();

    if (text.isEmpty) {
      setState(() {
        _referenceSearchResults.clear();
      });
      return;
    }

    _timerUpdateSuggestions = Timer(
      const Duration(milliseconds: 1000),
      () => trySearchReferences(text),
    );
  }

  /// Validate draft quote.
  /// Add draft to global quotes collection,
  /// and remove draft from global drafts collection.
  void validateDraft() async {
    final Quote quote = NavigationStateHelper.quote;
    if (quote is! DraftQuote) {
      return;
    }

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    if (userFirestoreSignal.value.id.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.user.unauthenticated".tr(),
      );
      return;
    }

    final UserRights rights = userFirestoreSignal.value.rights;
    if (!rights.canManageQuotes) {
      Utils.graphic.showSnackbar(
        context,
        message: "quote.error.user.not_admin".tr(),
      );
      return;
    }

    setState(() => _pageState = EnumPageState.validatingQuote);

    try {
      await FirebaseFirestore.instance.collection("quotes").add(
            NavigationStateHelper.quote.toMap(
              userId: userFirestoreSignal.value.id,
              operation: EnumQuoteOperation.validate,
            ),
          );

      // Delete draft.
      await _docRef?.delete();
      if (!mounted) return;

      navigateWhenFinished();
    } catch (error) {
      loggy.error(error);
      Utils.graphic.showSnackbar(
        context,
        message: "quote.validate.failed".tr(),
      );
    }
  }

  void onShowComplexBuilder() {
    setState(() => _showMinimalBuilder = false);
  }

  void onShowMinimalBuilder() {
    setState(() => _showMinimalBuilder = true);
  }

  void onSubmittedReferenceName(String value) {
    loggy.info("submit reference name: $value");
    onSaveDraft();
  }

  void onToggleCategory(String category, bool selected) {
    if (selected) {
      NavigationStateHelper.quote.categories.add(category);
    } else {
      NavigationStateHelper.quote.categories.remove(category);
    }

    updateQuoteDoc();
    setState(() {});
  }
}
