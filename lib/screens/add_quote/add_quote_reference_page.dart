import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/better_action_chip.dart";
import "package:kwotes/components/expand_input_chip.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/genre_chips.dart";
import "package:kwotes/screens/add_quote/reference_suggestion_row.dart";
import "package:kwotes/screens/add_quote/url_wrap.dart";
import "package:kwotes/types/reference.dart";

/// Page for adding or editing a reference.
class AddQuoteReferencePage extends StatelessWidget {
  const AddQuoteReferencePage({
    super.key,
    required this.reference,
    this.nameFocusNode,
    this.randomReferenceInt = 0,
    this.lastUsedUrls = const [],
    this.appBarRightChildren = const [],
    this.onNameChanged,
    this.onPictureUrlChanged,
    this.onPrimaryGenreChanged,
    this.onSecondaryGenreChanged,
    this.onTapReleasehDate,
    this.onSummaryChanged,
    this.onUrlChanged,
    this.nameController,
    this.onDeleteQuote,
    this.onToggleNagativeReleaseDate,
    this.referenceSuggestions = const [],
    this.onTapSuggestion,
    this.summaryController,
  });

  /// Main page data.
  final Reference reference;

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
  final void Function()? onTapReleasehDate;

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
            rightChildren: appBarRightChildren,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
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
                    textStyle: const TextStyle(
                      fontSize: 84.0,
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
                ),
                ReferenceSuggestionRow(
                  selectedReference: reference,
                  references: referenceSuggestions,
                  onTapSuggestion: onTapSuggestion,
                ),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    ExpandInputChip(
                      tooltip: "quote.add.reference.avatar".tr(),
                      avatar: CircleAvatar(
                        radius: 14.0,
                        backgroundImage:
                            const AssetImage("assets/images/autoportrait.png"),
                        foregroundImage: reference.urls.image.isNotEmpty
                            ? NetworkImage(reference.urls.image)
                            : null,
                      ),
                      hintText: "quote.add.links.example.web".tr(),
                      onTextChanged: onPictureUrlChanged,
                    ),
                    BetterActionChip(
                      onPressed: onTapReleasehDate,
                      tooltip: "quote.add.reference.dates.release".tr(),
                      avatar: Icon(TablerIcons.cake, color: iconColor),
                      label: Text(releaseText),
                    ),
                    BetterActionChip(
                      avatar: reference.release.beforeCommonEra
                          ? const Icon(TablerIcons.arrow_back)
                          : const Icon(TablerIcons.arrow_forward),
                      tooltip: "quote.add.reference.dates.negative.release"
                              ".explanation.${reference.release.beforeCommonEra}"
                          .tr(),
                      label: Text(
                        "quote.add.reference.dates.negative.release"
                                ".${reference.release.beforeCommonEra}"
                            .tr(),
                      ),
                      onPressed: onToggleNagativeReleaseDate,
                    ),
                  ],
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
                      filled: true,
                      hintMaxLines: 4,
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
