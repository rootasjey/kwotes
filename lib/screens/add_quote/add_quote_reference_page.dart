import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/add_reference_metadata_column.dart";
import "package:kwotes/screens/add_quote/add_reference_metadata_wrap.dart";
import "package:kwotes/screens/add_quote/genre_chips.dart";
import "package:kwotes/screens/add_quote/reference_suggestions.dart";
import "package:kwotes/screens/add_quote/url_wrap.dart";
import "package:kwotes/types/reference.dart";

/// Page for adding or editing a reference.
class AddQuoteReferencePage extends StatelessWidget {
  const AddQuoteReferencePage({
    super.key,
    required this.reference,
    this.isMobileSize = false,
    this.metadataOpened = true,
    this.nameFocusNode,
    this.randomReferenceInt = 0,
    this.lastUsedUrls = const [],
    this.appBarRightChildren = const [],
    this.onNameChanged,
    this.onPictureUrlChanged,
    this.onPrimaryGenreChanged,
    this.onSecondaryGenreChanged,
    this.onTapReleaseDate,
    this.onSummaryChanged,
    this.onUrlChanged,
    this.nameController,
    this.onDeleteQuote,
    this.onToggleMetadata,
    this.onToggleNagativeReleaseDate,
    this.referenceSuggestions = const [],
    this.onTapSuggestion,
    this.summaryController,
  });

  /// Expand metadata widget if true.
  final bool metadataOpened;

  /// Adapt user interface to moile size if true.
  final bool isMobileSize;

  /// Random int for displaying hint texts.
  final int randomReferenceInt;

  /// Focus node for reference's name input.
  final FocusNode? nameFocusNode;

  /// Callback fired to delete the quote we're editing.
  final void Function()? onDeleteQuote;

  /// Callback fired when reference's name has changed.
  final void Function(String name)? onNameChanged;

  /// Callback fired when text value for picture url has changed.
  final void Function(String url)? onPictureUrlChanged;

  /// Callback fired when reference's main genre has changed.
  final void Function(String mainGenre)? onPrimaryGenreChanged;

  /// Callback fired when reference's sub genre has changed.
  final void Function(String subGenre)? onSecondaryGenreChanged;

  /// Callback fired when reference's summary has changed.
  final void Function(String summary)? onSummaryChanged;

  /// Callback fired when a suggestion is tapped.
  final void Function(Reference reference)? onTapSuggestion;

  /// Callback fired when release date chip is tapped.
  final void Function()? onTapReleaseDate;

  /// Callback fired to toggle reference metadata widget size.
  final void Function()? onToggleMetadata;

  /// Callback fired when negative release date chip is tapped.
  final void Function()? onToggleNagativeReleaseDate;

  /// Callback fired when url input has changed.
  final void Function(String key, String value)? onUrlChanged;

  /// Search suggestions for reference.
  final List<Reference> referenceSuggestions;

  /// Last used urls.
  final List<String> lastUsedUrls;

  /// Right children of the application bar.
  final List<Widget> appBarRightChildren;

  /// Main page data.
  final Reference reference;

  /// Input controller for reference's name.
  final TextEditingController? nameController;

  /// Input controller for reference's summary.
  final TextEditingController? summaryController;

  @override
  Widget build(BuildContext context) {
    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5);

    final String releaseText = reference.release.dateEmpty
        ? "quote.add.reference.dates.$randomReferenceInt.original".tr()
        : Jiffy.parseFromDateTime(reference.release.original).yMMMMd;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ApplicationBar(
            isMobileSize: isMobileSize,
            rightChildren: appBarRightChildren,
          ),
          SliverPadding(
            padding: isMobileSize
                ? const EdgeInsets.only(
                    top: 24.0,
                    left: 24.0,
                    right: 24.0,
                    bottom: 190.0,
                  )
                : const EdgeInsets.only(
                    left: 48.0,
                    right: 90.0,
                    top: 24.0,
                    bottom: 240.0,
                  ),
            sliver: SliverList.list(
              children: [
                TextField(
                  maxLines: null,
                  autofocus: true,
                  controller: nameController,
                  focusNode: nameFocusNode,
                  onChanged: onNameChanged,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: Utils.calligraphy.title(
                    textStyle: TextStyle(
                      fontSize: isMobileSize ? 42.0 : 84.0,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.only(
                      left: 0.0,
                      bottom: 12.0,
                    ),
                    hintText:
                        "quote.add.reference.names.$randomReferenceInt".tr(),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                GenreChips(
                  selectedPrimaryGenre: reference.type.primary,
                  selectedSecondaryGenre: reference.type.secondary,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  onPrimaryGenreChanged: onPrimaryGenreChanged,
                  onSecondaryGenreChanged: onSecondaryGenreChanged,
                  primaryHintText:
                      "quote.add.reference.genres.primary.$randomReferenceInt"
                          .tr(),
                  secondaryHintText:
                      "quote.add.reference.genres.secondary.$randomReferenceInt"
                          .tr(),
                  show: !isMobileSize,
                ),
                ReferenceSuggestions(
                  isMobileSize: isMobileSize,
                  selectedReference: reference,
                  references: referenceSuggestions,
                  onTapSuggestion: onTapSuggestion,
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                AddReferenceMetadaColumn(
                  isOpen: metadataOpened,
                  onPrimaryGenreChanged: onPrimaryGenreChanged,
                  onSecondaryGenreChanged: onSecondaryGenreChanged,
                  onProfilePictureChanged: onPictureUrlChanged,
                  onTapReleaseDate: onTapReleaseDate,
                  onToggleNagativeReleaseDate: onToggleNagativeReleaseDate,
                  onToggleOpen: onToggleMetadata,
                  reference: reference,
                  releaseText: releaseText,
                  randomReferenceInt: randomReferenceInt,
                  show: isMobileSize,
                ),
                AddReferenceMetadataWrap(
                  show: !isMobileSize,
                  reference: reference,
                  iconColor: iconColor,
                  onPictureUrlChanged: onPictureUrlChanged,
                  onTapReleaseDate: onTapReleaseDate,
                  releaseText: releaseText,
                  onToggleNagativeReleaseDate: onToggleNagativeReleaseDate,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: TextField(
                    maxLines: null,
                    minLines: 2,
                    autofocus: false,
                    controller: summaryController,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: onSummaryChanged,
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w200,
                        height: 1.3,
                      ),
                    ),
                    decoration: InputDecoration(
                      filled: false,
                      contentPadding: const EdgeInsets.only(
                        top: 24.0,
                        right: 6.0,
                      ),
                      hintMaxLines: 8,
                      hintText:
                          "quote.add.reference.summaries.$randomReferenceInt"
                              .tr(),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                UrlWrap(
                  initialUrls: reference.urls,
                  lastUsed: lastUsedUrls,
                  onUrlChanged: onUrlChanged,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
