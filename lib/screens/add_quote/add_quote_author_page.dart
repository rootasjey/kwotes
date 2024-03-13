import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/add_author_metadata_column.dart";
import "package:kwotes/screens/add_quote/add_author_metadata_wrap.dart";
import "package:kwotes/screens/add_quote/author_suggestions.dart";
import "package:kwotes/screens/add_quote/cancel_button.dart";
import "package:kwotes/screens/add_quote/step_chip.dart";
import "package:kwotes/screens/add_quote/url_wrap.dart";
import "package:kwotes/types/author.dart";

/// Page for adding or editing an author.
class AddQuoteAuthorPage extends StatelessWidget {
  const AddQuoteAuthorPage({
    super.key,
    required this.author,
    required this.nameFocusNode,
    required this.jobFocusNode,
    required this.summaryFocusNode,
    this.canManageQuote = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.metadataOpened = true,
    this.randomAuthorInt = 0,
    this.onDeleteQuote,
    this.onJobChanged,
    this.onNameChanged,
    this.onProfilePictureChanged,
    this.onSummaryChanged,
    this.onToggleIsFictional,
    this.onTapBirthDate,
    this.onTapCancelButtonSummary,
    this.onTapShowSuggestionsAsList,
    this.onTapDeathDate,
    this.onToggleMetadata,
    this.onUrlChanged,
    this.lastUsedUrls = const [],
    this.appBarRightChildren = const [],
    this.onTapAuthorSuggestion,
    this.onTapCancelButtonName,
    this.onTapCancelButtonJob,
    this.onToggleNagativeBirthDate,
    this.onToggleNagativeDeathDate,
    this.authorSuggestions = const [],
    this.floatingActionButton,
    this.authorNameErrorText,
    this.jobController,
    this.nameController,
    this.summaryController,
  });

  /// Main page data.
  final Author author;

  /// Show metadata card if true.
  final bool canManageQuote;

  /// Adapt user interface to dark mode if true.
  final bool isDark;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Expand metadata widget if true.
  final bool metadataOpened;

  /// Random int for displaying hint texts.
  final int randomAuthorInt;

  /// Floating action button.
  final FloatingActionButton? floatingActionButton;

  /// Focus node for author's name input.
  final FocusNode nameFocusNode;

  /// Focus node for author's summary input.
  final FocusNode summaryFocusNode;

  /// Focus node for author's job input.
  final FocusNode jobFocusNode;

  /// Callback fired to delete the quote we're editing.
  final void Function()? onDeleteQuote;

  /// Callback fired when cancel button is tapped on summary input.
  final void Function()? onTapCancelButtonSummary;

  /// Callback fired when author's name has changed.
  final void Function(String name)? onNameChanged;

  /// Callback fired when author's job has changed.
  final void Function(String job)? onJobChanged;

  /// Callback fired when author's summary has changed.
  final void Function(String summary)? onSummaryChanged;

  /// Callback fired when author suggestion is tapped.
  final void Function(Author author)? onTapAuthorSuggestion;

  /// Callback fired when show as list button is tapped.
  final void Function()? onTapShowSuggestionsAsList;

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

  /// Callback fired when the cancel button is tapped on name.
  final void Function()? onTapCancelButtonName;

  /// Callback fired when the cancel button is tapped on job.
  final void Function()? onTapCancelButtonJob;

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

  /// Name error text.
  final String? authorNameErrorText;

  /// Author's name input controller.
  final TextEditingController? nameController;

  /// Author's job input controller.
  final TextEditingController? jobController;

  /// Author's summary input controller.
  final TextEditingController? summaryController;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color accentColor = Theme.of(context).primaryColor;
    const double borderWidth = 1.0;
    const double borderWidthFocusFactor = 1.4;
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8.0));
    const BorderRadius nameBorderRadius = BorderRadius.all(
      Radius.circular(2.0),
    );
    const BorderRadius jobBorderRadius = BorderRadius.all(
      Radius.circular(24.0),
    );
    final Color nameBorderColor =
        Theme.of(context).dividerColor.withOpacity(0.1);

    final ButtonStyle cancelButtonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    );

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
                    currentStep: 1,
                    isBonusStep: true,
                    isDark: isDark,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextFormField(
                    maxLines: null,
                    autofocus: false,
                    focusNode: nameFocusNode,
                    onChanged: onNameChanged,
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
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
                        show: nameFocusNode.hasFocus,
                        textStyle: const TextStyle(fontSize: 14.0),
                        onTapCancelButton: onTapCancelButtonName,
                        buttonStyle: cancelButtonStyle,
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                      errorText: authorNameErrorText,
                      hintText: "quote.add.author.names.$randomAuthorInt".tr(),
                      hintMaxLines: null,
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
                          width: borderWidth * borderWidthFocusFactor,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    onChanged: onJobChanged,
                    controller: jobController,
                    focusNode: jobFocusNode,
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontSize: 14.0,
                        height: 1.0,
                      ),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      constraints: const BoxConstraints(
                        minHeight: 12.0,
                        maxHeight: 36.0,
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                      hintText: "quote.add.author.jobs.$randomAuthorInt".tr(),
                      suffixIcon: CancelButton(
                        show: jobFocusNode.hasFocus,
                        onTapCancelButton: onTapCancelButtonJob,
                        textStyle: const TextStyle(fontSize: 14.0),
                        buttonStyle: cancelButtonStyle,
                      ),
                      errorText: authorNameErrorText,
                      hintMaxLines: null,
                      border: OutlineInputBorder(
                        borderRadius: jobBorderRadius,
                        borderSide: BorderSide(
                          width: borderWidth,
                          color: nameBorderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: jobBorderRadius,
                        borderSide: BorderSide(
                          width: borderWidth,
                          color: nameBorderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: jobBorderRadius,
                        borderSide: BorderSide(
                          width: borderWidth * borderWidthFocusFactor,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ),
                AuthorSuggestions(
                  authors: authorSuggestions,
                  isMobileSize: isMobileSize,
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  onTapSuggestion: onTapAuthorSuggestion,
                  onTapShowAsList: onTapShowSuggestionsAsList,
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
                  show: isMobileSize && canManageQuote,
                ),
                AddAuthorMetadaWrap(
                  author: author,
                  onProfilePictureChanged: onProfilePictureChanged,
                  onTapBirthDate: onTapBirthDate,
                  onTapDeathDate: onTapDeathDate,
                  onToggleNagativeBirthDate: onToggleNagativeBirthDate,
                  onToggleNagativeDeathDate: onToggleNagativeDeathDate,
                  onToggleIsFictional: onToggleIsFictional,
                  show: !isMobileSize && canManageQuote,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Stack(
                    children: [
                      TextFormField(
                        maxLines: null,
                        minLines: 2,
                        autofocus: false,
                        focusNode: summaryFocusNode,
                        controller: summaryController,
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
                            left: 12.0,
                            right: 12.0,
                          ),
                          hintMaxLines: 8,
                          hintText:
                              "quote.add.author.summaries.$randomAuthorInt"
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
                          top: 6.0,
                          right: 6.0,
                          child: CircleButton(
                            onTap: onTapCancelButtonSummary,
                            radius: 18.0,
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
