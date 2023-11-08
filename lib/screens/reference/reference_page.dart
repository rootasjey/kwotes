import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_image_viewer/easy_image_viewer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
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
  /// Show reference metadata if true.
  bool _metadataOpened = true;

  /// Firestore quote document reference.
  DocumentReference? _docRef;

  /// Subscription to author data.
  DocSnapshotStreamSubscription? _referenceSubscription;

  /// List of quotes associated with the author.
  final List<Quote> _referenceQuotes = [];

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Tooltip controller.
  final JustTheController _tooltipController = JustTheController();

  /// Author page data.
  Reference _reference = Reference.empty();

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
      Text(_reference.name, style: Utils.calligraphy.title()),
    );

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final bool canManageReference =
        userFirestoreSignal.value.rights.canManageReferences;

    final Color randomColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );

    return BasicShortcuts(
      onCancel: context.beamBack,
      child: Scaffold(
        floatingActionButton: canManageReference
            ? FloatingActionButton(
                onPressed: onEditReference,
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
              title: const SizedBox.shrink(),
              isMobileSize: isMobileSize,
              rightChildren: canManageReference
                  ? ReferenceAppBarChildren.getChildren(
                      context,
                      tooltipController: _tooltipController,
                      onDeleteReference: onDeleteReference,
                    )
                  : [],
            ),
            ReferencePageBody(
              areMetadataOpen: _metadataOpened,
              isMobileSize: isMobileSize,
              maxHeight: windowSize.height / 2,
              onTapSeeQuotes: onTapSeeQuotes,
              pageState: _pageState,
              onTapReferenceName: onTapReferenceName,
              onToggleMetadata: onToggleReferenceMetadata,
              randomColor: randomColor,
              referenceNameTextStyle: textWrapSolution.style,
              reference: _reference,
            ),
          ],
        ),
      ),
    );
  }

  void fetch() async {
    setState(() => _pageState = EnumPageState.loading);

    await Future.wait([
      fetchReference(widget.referenceId),
      // fetchReferenceQuotes(widget.referenceId),
    ]);

    setState(() => _pageState = EnumPageState.idle);
  }

  DocumentMap getQuery(String referenceId) {
    return FirebaseFirestore.instance.collection("references").doc(referenceId);
  }

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

  /// Initialize properties.
  void initProps() async {
    _metadataOpened = await Utils.vault.getReferenceMetadataOpened();
  }

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
      final reference = Reference.fromMap(authorMap);

      setState(() {
        _reference = reference;
      });
    }, onError: (error) {
      loggy.error(error);
    }, onDone: () {
      _referenceSubscription?.cancel();
    });
  }

  /// Navigate back.
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

  void onEditReference() {
    Beamer.of(context).beamToNamed(
      "/dashboard/edit/reference/${_reference.id}",
    );
  }

  void onTapReferenceName() {
    if (_reference.urls.image.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "reference.error.no_image".tr(),
      );
      return;
    }

    final ImageProvider imageProvider =
        Image.network(_reference.urls.image).image;

    showImageViewer(
      context,
      imageProvider,
      swipeDismissible: true,
      doubleTapZoomable: true,
    );
  }

  void onTapSeeQuotes() {
    Beamer.of(context).beamToNamed(
      SearchLocation.route,
      routeState: {
        "query": "quotes:reference:${_reference.id}",
        "subjectName": _reference.name,
      },
    );
  }

  /// Callback fired to toggle reference metadata widget size.
  void onToggleReferenceMetadata() {
    Utils.vault.setReferenceMetadataOpened(!_metadataOpened);
    setState(() => _metadataOpened = !_metadataOpened);
  }
}
