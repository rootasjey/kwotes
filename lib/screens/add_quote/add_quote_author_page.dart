import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/add_author_metadata_column.dart";
import "package:kwotes/screens/add_quote/add_author_metadata_wrap.dart";
import "package:kwotes/screens/add_quote/author_suggestions.dart";
import "package:kwotes/screens/add_quote/url_wrap.dart";
import "package:kwotes/types/author.dart";

/// Page for adding or editing an author.
class AddQuoteAuthorPage extends StatelessWidget {
  const AddQuoteAuthorPage({
    super.key,
    required this.author,
    this.metadataOpened = true,
    this.isMobileSize = false,
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
    this.onToggleMetadata,
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

  /// Expand metadata widget if true.
  final bool metadataOpened;

  /// Main page data.
  final Author author;

  /// Adapt user interface to moile size if true.
  final bool isMobileSize;

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

  /// Callback fired to toggle author metadata widget size.
  final void Function()? onToggleMetadata;

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
                TextFormField(
                  maxLines: null,
                  autofocus: true,
                  focusNode: nameFocusNode,
                  onChanged: onNameChanged,
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
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
                      bottom: 12.0,
                    ),
                    hintText: "quote.add.author.names.$randomAuthorInt".tr(),
                    hintMaxLines: null,
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
                AuthorSuggestions(
                  authors: authorSuggestions,
                  isMobileSize: isMobileSize,
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  onTapSuggestion: onTapAuthorSuggestion,
                  selectedAuthor: author,
                ),
                AddAuthorMetadaColumn(
                  author: author,
                  isOpen: metadataOpened,
                  onProfilePictureChanged: onProfilePictureChanged,
                  onTapBirthDate: onTapBirthDate,
                  onTapDeathDate: onTapDeathDate,
                  onToggleNagativeBirthDate: onToggleNagativeBirthDate,
                  onToggleNagativeDeathDate: onToggleNagativeDeathDate,
                  onToggleIsFictional: onToggleIsFictional,
                  onToggleOpen: onToggleMetadata,
                  randomAuthorInt: randomAuthorInt,
                  show: isMobileSize,
                ),
                AddAuthorMetadaWrap(
                  author: author,
                  onProfilePictureChanged: onProfilePictureChanged,
                  onTapBirthDate: onTapBirthDate,
                  onTapDeathDate: onTapDeathDate,
                  onToggleNagativeBirthDate: onToggleNagativeBirthDate,
                  onToggleNagativeDeathDate: onToggleNagativeDeathDate,
                  onToggleIsFictional: onToggleIsFictional,
                  randomAuthorInt: randomAuthorInt,
                  show: !isMobileSize,
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
                      filled: false,
                      contentPadding: const EdgeInsets.only(
                        top: 24.0,
                        right: 6.0,
                      ),
                      hintMaxLines: 8,
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
