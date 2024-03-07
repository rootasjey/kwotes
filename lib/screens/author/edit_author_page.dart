import "dart:async";

import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/add_quote/add_quote_app_bar_children.dart";
import "package:kwotes/screens/add_quote/add_quote_author_page.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/doc_snapshot_stream_subscription.dart";
import "package:kwotes/types/firestore/document_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/point_in_time.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/user/user_rights.dart";
import "package:loggy/loggy.dart";
import "package:verbal_expressions/verbal_expressions.dart";

class EditAuthorPage extends StatefulWidget {
  /// Page to edit a specific author.
  const EditAuthorPage({
    super.key,
    required this.authorId,
  });

  /// Unique id of the author to edit.
  final String authorId;

  @override
  State<EditAuthorPage> createState() => _EditAuthorPageState();
}

class _EditAuthorPageState extends State<EditAuthorPage> with UiLoggy {
  /// Author page data.
  Author _author = Author.empty();

  /// Initial author data.
  /// Use this to reset fields.
  Author _initialAuthor = Author.empty();

  /// Show author metadata if true.
  bool _metadataOpened = false;

  /// Firestore quote document reference.
  DocumentReference? _docRef;

  /// Author's subscription.
  DocSnapshotStreamSubscription? _authorSubscription;

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Author name focus node.
  final FocusNode _authorNameFocusNode = FocusNode();

  /// Used to request focus on the author job input.
  final FocusNode _authorJobFocusNode = FocusNode();

  /// Author summary focus node.
  final FocusNode _authorSummaryFocusNode = FocusNode();

  /// Last used urls (from cloud).
  final List<String> _lastUsedAuthorUrls = ["website", "wikipedia", "youtube"];

  /// Author's name text controller.
  final TextEditingController _authorNameController = TextEditingController();

  /// Author's summary text controller.
  final TextEditingController _authorSummaryController =
      TextEditingController();

  /// Debounce timer to update quote.
  Timer? _timerUpdateAuthor;

  /// Tooltip controller to confirm important action
  /// (e.g. delete author).
  final JustTheController _tooltipController = JustTheController();

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
    fetch();
  }

  @override
  void dispose() {
    _authorJobFocusNode.dispose();
    _authorNameController.dispose();
    _authorSubscription?.cancel();
    _authorSummaryController.dispose();
    _authorNameFocusNode.dispose();
    _timerUpdateAuthor?.cancel();
    _tooltipController.dispose();
    _author = Author.empty();
    _docRef = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "${"loading".tr()}...",
      );
    }

    if (_author.id.isEmpty) {
      return EmptyView.scaffold(
        context,
        title: "author.no".tr(),
        description: "author.error.id".tr(),
      );
    }

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final bool isAuthorValid = _author.name.isNotEmpty;

    final Color? fabForegroundColor = getFabForegroundColor(isAuthorValid);
    final Color? fabBackgroundColor = getFabBackgroundColor(isAuthorValid);

    return AddQuoteAuthorPage(
      appBarRightChildren: AddQuoteAppBarChildren.getChildren(
        context,
        onDeleteAuthor: onDeleteAuthor,
        tooltipController: _tooltipController,
        onResetAuthor: onResetAuthor,
      ),
      summaryFocusNode: _authorSummaryFocusNode,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onDone,
        backgroundColor: fabBackgroundColor,
        foregroundColor: fabForegroundColor,
        tooltip: isAuthorValid ? null : "author.save.name_required".tr(),
        elevation: 0.0,
        disabledElevation: 0.0,
        hoverElevation: 4.0,
        focusElevation: 0.0,
        highlightElevation: 0.0,
        splashColor: Colors.white,
        label: Text("done".tr()),
        icon: const Icon(TablerIcons.check),
      ),
      author: _author,
      authorNameErrorText:
          isAuthorValid ? null : "author.save.name_required".tr(),
      metadataOpened: _metadataOpened,
      jobFocusNode: _authorJobFocusNode,
      isMobileSize: isMobileSize,
      lastUsedUrls: _lastUsedAuthorUrls,
      nameFocusNode: _authorNameFocusNode,
      onNameChanged: onAuthorNameChanged,
      onJobChanged: onAuthorJobChanged,
      onProfilePictureChanged: onAuthorPictureUrlChanged,
      onSummaryChanged: onAuthorSummaryChanged,
      onTapBirthDate: onTapBirthDate,
      onTapDeathDate: onTapDeathDate,
      onToggleMetadata: onToggleMetadata,
      onToggleIsFictional: onToggleIsFictional,
      onToggleNagativeBirthDate: onToggleNagativeBirthDate,
      onToggleNagativeDeathDate: onToggleNagativeDeathDate,
      onUrlChanged: onAuthorUrlChanged,
      nameController: _authorNameController,
      summaryController: _authorSummaryController,
    );
  }

  void fetch() async {
    if (widget.authorId.isEmpty) {
      return;
    }

    if (NavigationStateHelper.author.id == widget.authorId) {
      _author = NavigationStateHelper.author;
      _initialAuthor = _author.copyWith();
      initFields();
    }

    await fetchAuthor();
  }

  Future<void> fetchAuthor() async {
    if (widget.authorId.isEmpty) {
      return;
    }

    if (_author.id.isEmpty) {
      setState(() => _pageState = EnumPageState.loading);
    }

    try {
      final DocumentMap query = getQuery();
      final DocumentSnapshotMap snapshot = await query.get();
      _docRef = snapshot.reference;

      final Json? data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return;
      }

      data["id"] = snapshot.id;
      _author = Author.fromMap(data);
      _initialAuthor = _author.copyWith();
      listenToAuthor(query);
    } catch (error) {
      loggy.error(error);
    } finally {
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Return the background color of the fab.
  Color? getFabBackgroundColor(bool isQuoteValid) {
    if (isQuoteValid) {
      return Constants.colors.foregroundPalette.first;
    }

    return Colors.grey.shade300;
  }

  /// Return the foreground color of the fab.
  Color? getFabForegroundColor(bool isQuoteValid) {
    if (!isQuoteValid) {
      return Theme.of(context).textTheme.bodyMedium?.color;
    }

    return Constants.colors.foregroundPalette.first.computeLuminance() > 0.4
        ? Colors.black
        : Colors.white;
  }

  DocumentMap getQuery() {
    return FirebaseFirestore.instance
        .collection("authors")
        .doc(widget.authorId);
  }

  /// Initialize fields with author data.
  void initFields() {
    _authorNameController.text = _author.name;
    _authorSummaryController.text = _author.summary;
  }

  /// Initialize props.
  void initProps() async {
    _metadataOpened = await Utils.vault.getAddAuthorMetadataOpened();
  }

  void listenToAuthor(DocumentMap query) {
    _authorSubscription = query.snapshots().skip(1).listen(
      (DocumentSnapshotMap snapshot) {
        final Json? data = snapshot.data();

        if (!snapshot.exists || data == null) {
          return;
        }

        setState(() {
          data["id"] = snapshot.id;
          _author = Author.fromMap(data);
        });
      },
      onError: (error) {
        loggy.error(error);
      },
      onDone: () {
        _authorSubscription?.cancel();
      },
    );
  }

  void onDeleteAuthor() async {
    _authorSubscription?.cancel();

    try {
      await getQuery().delete();
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: "author.delete.failed".tr(),
      );
    }
  }

  /// Callback fired when author's name has changed.
  void onAuthorNameChanged(String name) {
    _author = _author.copyWith(
      name: name,
    );

    updateQuoteDoc();
  }

  /// Callback fired when author's job has changed.
  void onAuthorJobChanged(String job) {
    _author = _author.copyWith(
      job: job,
    );

    updateQuoteDoc();
  }

  /// Callback fired when url input for profile picture has changed.
  void onAuthorPictureUrlChanged(String url) {
    _author = _author.copyWith(
        urls: _author.urls.copyWith(
      image: url,
    ));
    updateQuoteDoc();

    if (_urlVerbExp.hasMatch(url)) {
      setState(() {});
    }
  }

  /// Callback fired when author's summary has changed.
  void onAuthorSummaryChanged(String summary) {
    _author = _author.copyWith(
      summary: summary,
    );

    updateQuoteDoc();
  }

  /// Callback fired when an url input has changed for author.
  void onAuthorUrlChanged(String key, String value) {
    _author = _author.copyWith(
        urls: _author.urls.copyWithKey(
      key: key,
      value: value,
    ));

    updateQuoteDoc();
  }

  /// Method fired when all edits are done.
  void onDone() {
    final BeamerDelegate beamer = Beamer.of(context);
    if (beamer.canBeamBack) {
      beamer.beamBack();
      return;
    }

    beamer.beamToNamed(HomeLocation.route);
  }

  /// Reset the reference to initial data before navigating to this page.
  void onResetAuthor() {
    setState(() {
      _author = _initialAuthor.copyWith();
      initProps();
      initFields();
    });
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

    final PointInTime authorBirth = _author.birth;

    setState(() {
      _author = _author.copyWith(
          birth: authorBirth.copyWith(
        date: pickedDate,
        isDateEmpty: false,
      ));
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

    final PointInTime authorDeath = _author.death;

    setState(() {
      _author = _author.copyWith(
        death: authorDeath.copyWith(
          date: pickedDate,
          isDateEmpty: false,
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired to toggle author metadata widget size.
  void onToggleMetadata() {
    Utils.vault.setAddAuthorMetadataOpened(!_metadataOpened);
    setState(() => _metadataOpened = !_metadataOpened);
  }

  /// Callback fired when fictional value has changed.
  void onToggleIsFictional() {
    setState(() {
      _author = _author.copyWith(
        isFictional: !_author.isFictional,
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired when nagative birth date chip is tapped.
  void onToggleNagativeBirthDate() {
    setState(() {
      _author = _author.copyWith(
        birth: _author.birth.copyWith(
          beforeCommonEra: !_author.birth.beforeCommonEra,
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired when nagative death date chip is tapped.
  void onToggleNagativeDeathDate() {
    setState(() {
      _author = _author.copyWith(
        death: _author.death.copyWith(
          beforeCommonEra: !_author.death.beforeCommonEra,
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Update quote document in firestore.
  void updateQuoteDoc() {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final UserFirestore userFirestore = userFirestoreSignal.value;

    if (userFirestore.id.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "signin.again".tr(),
      );
      return;
    }

    final UserRights userRights = userFirestore.rights;
    if (!userRights.canManageAuthors) {
      return;
    }

    // Prevent updating with empty name.
    if (_author.name.isEmpty) {
      setState(() {});
      return;
    }

    _timerUpdateAuthor?.cancel();
    _timerUpdateAuthor = Timer(const Duration(milliseconds: 1000), () {
      _docRef?.update(_author.toMap());
    });
  }
}
