import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/better_action_chip.dart";
import "package:kwotes/components/expand_input_chip.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/author_suggestion_row.dart";
import "package:kwotes/screens/add_quote/url_wrap.dart";
import "package:kwotes/types/author.dart";

/// Page for adding or editing an author.
class AddQuoteAuthorPage extends StatelessWidget {
  const AddQuoteAuthorPage({
    super.key,
    required this.author,
    this.nameFocusNode,
    this.randomAuthorInt = 0,
    this.onDeleteQuote,
    this.onJobChanged,
    this.onNameChanged,
    this.onProfilePictureChanged,
    this.onSummaryChanged,
    this.onToggleIsFictional,
    this.onTapBirthDate,
    this.onTapDeathDate,
    this.onUrlChanged,
    this.lastUsedUrls = const [],
    this.appBarRightChildren = const [],
    this.onTapAuthorSuggestion,
    this.onToggleNagativeBirthDate,
    this.onToggleNagativeDeathDate,
    this.authorSuggestions = const [],
    this.nameController,
    this.summaryController,
  });

  /// Main page data.
  final Author author;

  /// Random int for displaying hint texts.
  final int randomAuthorInt;

  /// Focus node for author's name input.
  final FocusNode? nameFocusNode;

  /// Callback fired to delete the quote we're editing.
  final void Function()? onDeleteQuote;

  /// Callback fired when author's name has changed.
  final void Function(String name)? onNameChanged;

  /// Callback fired when author's job has changed.
  final void Function(String job)? onJobChanged;

  /// Callback fired when author's summary has changed.
  final void Function(String summary)? onSummaryChanged;

  /// Callback fired when author suggestion is tapped.
  final void Function(Author author)? onTapAuthorSuggestion;

  /// Callback fired when birth date chip is tapped.
  final void Function()? onTapBirthDate;

  /// Callback fired when death date chip is tapped.
  final void Function()? onTapDeathDate;

  /// Callback fired when BCE birth date chip is tapped.
  final void Function()? onToggleNagativeBirthDate;

  /// Callback fired when BCE death date chip is tapped.
  final void Function()? onToggleNagativeDeathDate;

  /// Callback fired when text value for profile picture has changed.
  final void Function(String url)? onProfilePictureChanged;

  /// Callback fired when fictional value has changed.
  final void Function()? onToggleIsFictional;

  /// Callback fired when one of url inputs has changed
  /// (e.g. wikipedia, website).
  final void Function(String key, String value)? onUrlChanged;

  /// Search suggestions for author.
  final List<Author> authorSuggestions;

  /// Right children of the application bar.
  final List<Widget> appBarRightChildren;

  /// Last used urls.
  final List<String> lastUsedUrls;

  /// Author's name input controller.
  final TextEditingController? nameController;

  /// Author's summary input controller.
  final TextEditingController? summaryController;

  @override
  Widget build(BuildContext context) {
    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5);

    final String birthText = author.birth.dateEmpty
        ? "quote.add.author.dates.$randomAuthorInt.birth".tr()
        : Jiffy.parseFromDateTime(author.birth.date).yMMMMd;

    final String deathText = author.death.dateEmpty
        ? "quote.add.author.dates.$randomAuthorInt.death".tr()
        : Jiffy.parseFromDateTime(author.death.date).yMMMMd;

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
                TextFormField(
                  maxLines: null,
                  autofocus: true,
                  focusNode: nameFocusNode,
                  onChanged: onNameChanged,
                  controller: nameController,
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
                    hintText: "quote.add.author.names.$randomAuthorInt".tr(),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    onChanged: onJobChanged,
                    initialValue: author.job,
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        height: 1.0,
                      ),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.only(
                        left: 0.0,
                        top: 6.0,
                      ),
                      hintText: "quote.add.author.jobs.$randomAuthorInt".tr(),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                AuthorSuggestionRow(
                  authors: authorSuggestions,
                  onTapSuggestion: onTapAuthorSuggestion,
                  selectedAuthor: author,
                ),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    ExpandInputChip(
                      tooltip: "quote.add.author.avatar".tr(),
                      avatar: CircleAvatar(
                        radius: 14.0,
                        backgroundImage:
                            const AssetImage("assets/images/autoportrait.png"),
                        foregroundImage: author.urls.image.isNotEmpty
                            ? NetworkImage(author.urls.image)
                            : null,
                      ),
                      hintText: "quote.add.links.example.web".tr(),
                      onTextChanged: onProfilePictureChanged,
                    ),
                    BetterActionChip(
                      onPressed: onTapBirthDate,
                      tooltip: "quote.add.author.dates.birth".tr(),
                      avatar: Icon(TablerIcons.cake, color: iconColor),
                      label: Text(birthText),
                    ),
                    BetterActionChip(
                      avatar: author.birth.beforeCommonEra
                          ? const Icon(TablerIcons.arrow_back)
                          : const Icon(TablerIcons.arrow_forward),
                      tooltip: "quote.add.author.dates.negative.birth"
                              ".explanation.${author.birth.beforeCommonEra}"
                          .tr(),
                      label: Text(
                        "quote.add.author.dates.negative"
                                ".birth.${author.birth.beforeCommonEra}"
                            .tr(),
                      ),
                      onPressed: onToggleNagativeBirthDate,
                    ),
                    if (deathText.isNotEmpty)
                      BetterActionChip(
                        onPressed: onTapDeathDate,
                        tooltip: "quote.add.author.dates.death".tr(),
                        avatar: Icon(TablerIcons.skull, color: iconColor),
                        label: Text(deathText),
                      ),
                    if (deathText.isNotEmpty)
                      BetterActionChip(
                        avatar: author.death.beforeCommonEra
                            ? const Icon(TablerIcons.arrow_back)
                            : const Icon(TablerIcons.arrow_forward),
                        tooltip: "quote.add.author.dates.negative"
                                ".death.explanation.${author.death.beforeCommonEra}"
                            .tr(),
                        label: Text(
                          "quote.add.author.dates.negative"
                                  ".death.${author.death.beforeCommonEra}"
                              .tr(),
                        ),
                        onPressed: onToggleNagativeDeathDate,
                      ),
                    BetterActionChip(
                      avatar: null,
                      tooltip: "quote.add.author"
                              ".fictional.explanation.${author.isFictional}"
                          .tr(),
                      label: Text(
                        "quote.add.author.fictional.${author.isFictional}".tr(),
                      ),
                      onPressed: onToggleIsFictional,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: TextFormField(
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
                          "quote.add.author.summaries.$randomAuthorInt".tr(),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                UrlWrap(
                  initialUrls: author.urls,
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
