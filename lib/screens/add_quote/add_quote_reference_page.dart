import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/add_reference_metadata_column.dart";
import "package:kwotes/screens/add_quote/add_reference_metadata_wrap.dart";
import "package:kwotes/screens/add_quote/cancel_button.dart";
import "package:kwotes/screens/add_quote/genre_chips.dart";
import "package:kwotes/screens/add_quote/reference_suggestions.dart";
import "package:kwotes/screens/add_quote/step_chip.dart";
import "package:kwotes/screens/add_quote/url_wrap.dart";
import "package:kwotes/types/reference.dart";

/// Page for adding or editing a reference.
class AddQuoteReferencePage extends StatelessWidget {
  const AddQuoteReferencePage({
    super.key,
    required this.reference,
    required this.nameFocusNode,
    required this.summaryFocusNode,
    this.isDark = false,
    this.isMobileSize = false,
    this.metadataOpened = true,
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
    this.onTapCancelButtonName,
    this.onToggleMetadata,
    this.onToggleNagativeReleaseDate,
    this.referenceSuggestions = const [],
    this.onTapShowSuggestionsAsList,
    this.onTapSuggestion,
    this.summaryController,
    this.floatingActionButton,
    this.referenceNameErrorText,
    this.onTapCancelButtonSummary,
  });

  /// Adapt user interface to dark mode if true.
  final bool isDark;

  /// Adapt user interface to moile size if true.
  final bool isMobileSize;

  /// Expand metadata widget if true.
  final bool metadataOpened;

  /// Random int for displaying hint texts.
  final int randomReferenceInt;

  /// Focus node for reference's name input.
  final FocusNode nameFocusNode;

  /// Focus node for reference's summary input.
  final FocusNode summaryFocusNode;

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

  /// Callback fired when the cancel button is tapped.
  final void Function()? onTapCancelButtonName;

  /// Callback fired when cancel button is tapped on summary input.
  final void Function()? onTapCancelButtonSummary;

  /// Callback fired when show as list button is tapped.
  final void Function()? onTapShowSuggestionsAsList;

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

  /// Name error text.
  final String? referenceNameErrorText;

  /// Input controller for reference's name.
  final TextEditingController? nameController;

  /// Input controller for reference's summary.
  final TextEditingController? summaryController;

  /// Floating action button.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color accentColor = Theme.of(context).primaryColor;
    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5);

    final String releaseText = reference.release.isEmpty
        ? "quote.add.reference.dates.choose".tr()
        : Jiffy.parseFromDateTime(reference.release.original).yMMMMd;

    const double borderWidth = 1.0;
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8.0));
    const BorderRadius nameBorderRadius =
        BorderRadius.all(Radius.circular(2.0));
    final Color nameBorderColor =
        Theme.of(context).dividerColor.withOpacity(0.1);

    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: CustomScrollView(
        slivers: [
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
                Align(
                  alignment: Alignment.topRight,
                  child: StepChip(
                    currentStep: 4,
                    isDark: isDark,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextField(
                    maxLines: null,
                    autofocus: false,
                    controller: nameController,
                    focusNode: nameFocusNode,
                    onChanged: onNameChanged,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    style: Utils.calligraphy.title(
                      textStyle: TextStyle(
                        fontSize: isMobileSize ? 24.0 : 84.0,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIcon: CancelButton(
                        onTapCancelButton: onTapCancelButtonName,
                        show: nameFocusNode.hasFocus,
                        textStyle: const TextStyle(fontSize: 14.0),
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                      errorText: referenceNameErrorText,
                      hintText:
                          "quote.add.reference.names.$randomReferenceInt".tr(),
                      border: OutlineInputBorder(
                        borderRadius: nameBorderRadius,
                        borderSide: BorderSide(
                          width: borderWidth,
                          color: nameBorderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: nameBorderRadius,
                        borderSide: BorderSide(
                          width: borderWidth,
                          color: nameBorderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: nameBorderRadius,
                        borderSide: BorderSide(
                          width: borderWidth,
                          color: accentColor,
                        ),
                      ),
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
                  onTapShowAsList: onTapShowSuggestionsAsList,
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
                  child: Stack(
                    children: [
                      TextField(
                        maxLines: null,
                        minLines: 2,
                        autofocus: false,
                        controller: summaryController,
                        focusNode: summaryFocusNode,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: onSummaryChanged,
                        style: Utils.calligraphy.body(
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w200,
                            height: 1.3,
                          ),
                        ),
                        decoration: InputDecoration(
                          filled: false,
                          contentPadding: const EdgeInsets.only(
                            top: 24.0,
                            right: 12.0,
                            left: 12.0,
                          ),
                          hintMaxLines: 8,
                          hintText:
                              "quote.add.reference.summaries.$randomReferenceInt"
                                  .tr(),
                          border: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              color: accentColor.withOpacity(0.6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              color: accentColor.withOpacity(0.6),
                            ),
                          ),
                          disabledBorder: const OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              // color: foregroundColor,
                            ),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              color: Colors.pink,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                      if (summaryFocusNode.hasFocus)
                        Positioned(
                          top: 4.0,
                          right: 4.0,
                          child: CircleButton(
                            onTap: onTapCancelButtonSummary,
                            radius: 16.0,
                            tooltip: "cancel".tr(),
                            icon: Icon(
                              TablerIcons.fold_down,
                              size: 24.0,
                              color: foregroundColor?.withOpacity(0.6),
                            ),
                          ),
                        ),
                    ],
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
