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
import "package:kwotes/screens/add_quote/add_quote_reference_page.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/enums/enum_main_genre.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/firestore/doc_snapshot_stream_subscription.dart";
import "package:kwotes/types/firestore/document_map.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/user/user_rights.dart";
import "package:loggy/loggy.dart";
import "package:verbal_expressions/verbal_expressions.dart";

class EditReferencePage extends StatefulWidget {
  const EditReferencePage({
    super.key,
    required this.referenceId,
  });

  /// Unique id of the reference.
  final String referenceId;

  @override
  State<EditReferencePage> createState() => _EditReferencePageState();
}

class _EditReferencePageState extends State<EditReferencePage> with UiLoggy {
  /// Show reference metadata if true.
  bool _metadataOpened = false;

  /// Firestore quote document reference.
  DocumentReference? _docRef;

  /// Reference's subscription.
  DocSnapshotStreamSubscription? _referenceSubscription;

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Author name focus node.
  final FocusNode _referenceNameFocusNode = FocusNode();

  /// Author name focus node.
  final FocusNode _referenceSummaryFocusNode = FocusNode();

  /// Last used urls (from cloud).
  final List<String> _lastUsedReferenceUrls = [
    "website",
    "wikipedia",
    "youtube"
  ];

  /// Reference page data.
  Reference _reference = Reference.empty();

  /// Initial reference.
  /// Use this to reset fields.
  Reference _initialReference = Reference.empty();

  /// Reference's name text controller.
  final TextEditingController _referenceNameController =
      TextEditingController();

  /// Reference's summary text controller.
  final TextEditingController _referenceSummaryController =
      TextEditingController();

  /// Debounce timer to update quote.
  Timer? _timerUpdateReference;

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
    _referenceNameController.dispose();
    _referenceSubscription?.cancel();
    _referenceSummaryController.dispose();
    _referenceNameFocusNode.dispose();
    _referenceSummaryFocusNode.dispose();
    _timerUpdateReference?.cancel();
    _tooltipController.dispose();
    _reference = Reference.empty();
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

    if (_reference.id.isEmpty) {
      return EmptyView.scaffold(
        context,
        title: "author.no".tr(),
        description: "author.error.id".tr(),
      );
    }

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final bool isAuthorValid = _reference.name.isNotEmpty;

    final Color? fabForegroundColor = getFabForegroundColor(isAuthorValid);
    final Color? fabBackgroundColor = getFabBackgroundColor(isAuthorValid);

    return AddQuoteReferencePage(
      appBarRightChildren: AddQuoteAppBarChildren.getChildren(
        context,
        onDeleteReference: onDeleteReference,
        onResetReference: onResetReference,
        tooltipController: _tooltipController,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onDone,
        backgroundColor: fabBackgroundColor,
        foregroundColor: fabForegroundColor,
        tooltip: isAuthorValid ? null : "quote.submit.required".tr(),
        elevation: 6.0,
        disabledElevation: 0.0,
        hoverElevation: 4.0,
        focusElevation: 0.0,
        highlightElevation: 0.0,
        splashColor: Colors.white,
        icon: const Icon(TablerIcons.check),
        label: Text("done".tr()),
      ),
      referenceNameErrorText:
          isAuthorValid ? null : "author.save.name_required".tr(),
      isMobileSize: isMobileSize,
      lastUsedUrls: _lastUsedReferenceUrls,
      metadataOpened: _metadataOpened,
      nameController: _referenceNameController,
      nameFocusNode: _referenceNameFocusNode,
      onNameChanged: onReferenceNameChanged,
      onPictureUrlChanged: onReferencePictureUrlChanged,
      onPrimaryGenreChanged: onPrimaryGenreChanged,
      onSecondaryGenreChanged: onSecondaryGenreChanged,
      onSummaryChanged: onReferenceSummaryChanged,
      onTapReleaseDate: onTapReleaseDate,
      onToggleMetadata: onToggleMetadata,
      onToggleNagativeReleaseDate: onToggleNagativeReleaseDate,
      onUrlChanged: onReferenceUrlChanged,
      reference: _reference,
      summaryController: _referenceSummaryController,
      summaryFocusNode: _referenceSummaryFocusNode,
    );
  }

  void fetch() async {
    if (widget.referenceId.isEmpty) {
      return;
    }

    if (NavigationStateHelper.reference.id == widget.referenceId) {
      _reference = NavigationStateHelper.reference;
      _initialReference = _reference.copyWith();
      initFields();
    }

    await fetchReference();
  }

  Future<void> fetchReference() async {
    if (widget.referenceId.isEmpty) {
      return;
    }

    if (_reference.id.isEmpty) {
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
      _reference = Reference.fromMap(data);
      _initialReference = _reference.copyWith();
      listenToReference(query);
      initFields();
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
        .collection("references")
        .doc(widget.referenceId);
  }

  /// Initialize fields with reference data.
  void initFields() {
    _referenceNameController.text = _reference.name;
    _referenceSummaryController.text = _reference.summary;
  }

  /// Initialize props.
  void initProps() async {
    _metadataOpened = await Utils.vault.getAddAuthorMetadataOpened();
  }

  /// Listen to reference.
  void listenToReference(DocumentMap query) {
    _referenceSubscription = query.snapshots().skip(1).listen(
      (DocumentSnapshotMap snapshot) {
        final Json? data = snapshot.data();

        if (!snapshot.exists || data == null) {
          return;
        }

        setState(() {
          data["id"] = snapshot.id;
          _reference = Reference.fromMap(data);
        });
      },
      onError: (error) {
        loggy.error(error);
      },
      onDone: () {
        _referenceSubscription?.cancel();
      },
    );
  }

  void onDeleteReference() async {
    _referenceSubscription?.cancel();

    try {
      await getQuery().delete();
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: "reference.delete.failed".tr(),
      );
    }
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

  /// Callback fired when main genre has changed.
  void onPrimaryGenreChanged(String mainGenre) {
    final bool isValidGenre =
        EnumMainGenre.values.any((x) => x.name == mainGenre);

    if (!isValidGenre) {
      return;
    }

    _reference = _reference.copyWith(
      type: _reference.type.copyWith(
        primary: mainGenre,
      ),
    );

    updateQuoteDoc();
  }

  /// Callback fired when reference's name has changed.
  void onReferenceNameChanged(String name) {
    _reference = _reference.copyWith(
      name: name,
    );

    updateQuoteDoc();
  }

  /// Callback fired when reference's picture url has changed.
  void onReferencePictureUrlChanged(String url) {
    _reference = _reference.copyWith(
      urls: _reference.urls.copyWith(
        image: url,
      ),
    );

    updateQuoteDoc();

    if (_urlVerbExp.hasMatch(url)) {
      setState(() {});
    }
  }

  /// Callback fired when reference's summary has changed.
  void onReferenceSummaryChanged(String summary) {
    _reference = _reference.copyWith(
      summary: summary,
    );

    updateQuoteDoc();
  }

  /// Callback fired when one of the reference's urls (e.g. wikipedia)
  /// has changed.
  void onReferenceUrlChanged(String key, String value) {
    _reference = _reference.copyWith(
      urls: _reference.urls.copyWithKey(
        key: key,
        value: value,
      ),
    );

    updateQuoteDoc();
  }

  /// Reset the reference to initial data before navigating to this page.
  void onResetReference() {
    setState(() {
      _reference = _initialReference.copyWith();
      initProps();
      initFields();
    });
  }

  /// Callback fired when secondary genre has changed.
  void onSecondaryGenreChanged(String subGenre) {
    _reference = _reference.copyWith(
      type: _reference.type.copyWith(
        secondary: subGenre,
      ),
    );

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

    setState(() {
      _reference = _reference.copyWith(
        release: _reference.release.copyWith(
          original: pickedDate,
          beforeCommonEra: _reference.release.beforeCommonEra,
          isEmpty: false,
        ),
      );
    });

    updateQuoteDoc();
  }

  /// Callback fired to toggle author metadata widget size.
  void onToggleMetadata() {
    Utils.vault.setAddReferenceMetadataOpened(!_metadataOpened);
    setState(() => _metadataOpened = !_metadataOpened);
  }

  /// Switch between before and after common era.
  void onToggleNagativeReleaseDate() {
    setState(() {
      _reference = _reference.copyWith(
        release: _reference.release.copyWith(
          beforeCommonEra: !_reference.release.beforeCommonEra,
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
    if (_reference.name.isEmpty) {
      setState(() {});
      return;
    }

    _timerUpdateReference?.cancel();
    _timerUpdateReference = Timer(
      const Duration(milliseconds: 1000),
      () => _docRef?.update(_reference.toMap()),
    );
  }
}
