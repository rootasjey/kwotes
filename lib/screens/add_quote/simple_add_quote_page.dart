import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/screens/add_quote/quote_language_selector.dart";
import "package:kwotes/screens/add_quote/simple_add_quote_author.dart";
import "package:kwotes/screens/add_quote/simple_add_quote_content.dart";
import "package:kwotes/screens/add_quote/simple_add_quote_reference.dart";
import "package:kwotes/screens/add_quote/simple_app_bar.dart";
import "package:kwotes/screens/add_quote/simple_header.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/intents/save_intent.dart";
import "package:kwotes/types/intents/submit_intent.dart";
import "package:kwotes/types/user/user_firestore.dart";

class SimpleAddQuotePage extends StatelessWidget {
  const SimpleAddQuotePage({
    super.key,
    required this.contentController,
    required this.onSelectLanguage,
    required this.onQuoteContentChanged,
    required this.onSaveShortcut,
    required this.onSubmitShortcut,
    required this.saveButton,
    required this.shortcuts,
    required this.contentFocusNode,
    required this.authorNameFocusNode,
    required this.authorNameController,
    required this.referenceNameFocusNode,
    required this.referenceNameController,
    required this.languageSelector,
    this.isMobileSize = false,
    this.hasHistory = false,
    this.isDark = false,
    this.canManageQuotes = false,
    this.foregroundColor,
    this.randomAuthorInt = 0,
    this.randomReferenceInt = 0,
    this.onAuthorNameChanged,
    this.onReferenceNameChanged,
    this.onTapCancelButtonAuthorName,
    this.cancelAuthorNameFocusNode,
    this.cancelReferenceNameFocusNode,
    this.onSubmittedReferenceName,
    this.onTapCancelButtonContentName,
    this.onTapCancelButtonReferenceName,
    this.onShowComplexBuilder,
  });

  /// Display "details" UI button if true.
  final bool canManageQuotes;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Show back button if true.
  final bool hasHistory;

  /// Adapt user interface to dark mode if true.
  final bool isDark;

  /// Foreground color for text.
  final Color? foregroundColor;

  /// Current language selected.
  final EnumLanguageSelection _languageSelection = EnumLanguageSelection.en;

  /// Used to request focus on the content input and to show cancel button.
  final FocusNode contentFocusNode;

  /// Used to request focus on the author name input and to show cancel button.
  final FocusNode authorNameFocusNode;

  /// Cancel button focus node to deactivate focus.
  final FocusNode? cancelAuthorNameFocusNode;

  /// Cancel button focus node to deactivate focus.
  final FocusNode? cancelReferenceNameFocusNode;

  /// Used to request focus on the reference name input and to show cancel button.
  final FocusNode referenceNameFocusNode;

  /// Callback fired when a new language is selected.
  final void Function(EnumLanguageSelection languageSelection) onSelectLanguage;

  /// Callback fired when quote content has changed.
  final void Function(String newValue)? onQuoteContentChanged;

  /// Callback fired when author name has changed.
  final void Function(String newValue)? onAuthorNameChanged;

  /// Callback fired when reference name has changed.
  final void Function(String newValue)? onReferenceNameChanged;

  /// Callback fired when save shortcut has been activated.
  final Object? Function(SaveIntent intent) onSaveShortcut;

  /// Callback fired when submit shortcut has been activated.
  final Object? Function(SubmitIntent intent) onSubmitShortcut;

  /// Callback fired when "enter" key is pressed on reference input.
  final void Function(String value)? onSubmittedReferenceName;

  /// Callback fired when cancel button is pressed on quote content input.
  final void Function()? onTapCancelButtonContentName;

  /// Callback fired when cancel button is pressed on author name input.
  final void Function()? onTapCancelButtonAuthorName;

  /// Callback fired when cancel button is pressed on reference name input.
  final void Function()? onTapCancelButtonReferenceName;

  /// Callback fired when show complex builder button is pressed.
  final void Function()? onShowComplexBuilder;

  /// Int between 0 and 9 to select a random author hint.
  final int randomAuthorInt;

  /// Int between 0 and 9 to select a random reference hint.
  final int randomReferenceInt;

  /// Shortcuts for this page.
  final Map<SingleActivator, Intent> shortcuts;

  /// Auto detected languge string value (e.g. "en").
  final String _autoDetectedLanguage = "";

  /// Text editing controller for quote content.
  final TextEditingController contentController;

  /// Text editing controller for author name.
  final TextEditingController authorNameController;

  /// Text editing controller for reference name.
  final TextEditingController referenceNameController;

  /// Save button widget.
  final Widget saveButton;

  /// Language selector.
  final Widget languageSelector;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets margin = isMobileSize
        ? const EdgeInsets.only(
            top: 12.0,
            left: 24.0,
            right: 24.0,
          )
        : const EdgeInsets.only(
            left: 36.0,
            top: 12.0,
            right: 36.0,
          );

    final BoxConstraints boxConstraints = isMobileSize
        ? const BoxConstraints(
            maxWidth: 500.0,
          )
        : const BoxConstraints(
            maxWidth: 500.0,
          );

    final Signal<UserFirestore> signUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: onSaveShortcut,
          ),
          SubmitIntent: CallbackAction<SubmitIntent>(
            onInvoke: onSubmitShortcut,
          ),
        },
        child: SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SimpleAppBar(
                  textTitle: "quote.new".tr().toUpperCase(),
                ),
                SignalBuilder(
                  signal: signUserFirestore,
                  builder: (
                    BuildContext context,
                    UserFirestore userFirestore,
                    Widget? child,
                  ) {
                    return SimpleHeader(
                      isDark: isDark,
                      show: userFirestore.rights.canManageQuotes,
                      boxConstraints: boxConstraints,
                      languageSelector: languageSelector,
                      margin: const EdgeInsets.only(
                        top: 24.0,
                        left: 28.0,
                        right: 28.0,
                      ),
                      onShowComplexBuilder: onShowComplexBuilder,
                    );
                  },
                ),
                SimpleAddQuoteContent(
                  isDark: isDark,
                  isMobileSize: isMobileSize,
                  boxConstraints: boxConstraints,
                  onContentChanged: onQuoteContentChanged,
                  contentController: contentController,
                  contentFocusNode: contentFocusNode,
                  languageSelector: QuoteLanguageSelector(
                    languageSelection: _languageSelection,
                    autoDetectedLanguage: _autoDetectedLanguage,
                    isDark: isDark,
                    foregroundColor: foregroundColor,
                    onSelectLanguage: onSelectLanguage,
                  ),
                  margin: margin.copyWith(top: isMobileSize ? 6.0 : 42.0),
                ),
                SimpleAddQuoteAuthor(
                  isMobileSize: isMobileSize,
                  margin: margin,
                  boxConstraints: boxConstraints,
                  authorNameFocusNode: authorNameFocusNode,
                  cancelAuthorNameFocusNode: cancelAuthorNameFocusNode,
                  nameController: authorNameController,
                  onNameChanged: onAuthorNameChanged,
                  onTapCancelButtonName: onTapCancelButtonAuthorName,
                  randomAuthorInt: randomAuthorInt,
                ),
                SimpleAddQuoteReference(
                  isMobileSize: isMobileSize,
                  margin: margin,
                  boxConstraints: boxConstraints,
                  cancelReferenceNameFocusNode: cancelReferenceNameFocusNode,
                  nameController: referenceNameController,
                  nameFocusNode: referenceNameFocusNode,
                  onNameChanged: onReferenceNameChanged,
                  onTapCancelButtonName: onTapCancelButtonReferenceName,
                  randomReferenceInt: randomReferenceInt,
                  onSubmitted: onSubmittedReferenceName,
                ),
                SliverPadding(
                  padding: margin.add(
                    const EdgeInsets.only(
                      top: 12.0,
                      bottom: 84.0,
                    ),
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: boxConstraints,
                        child: saveButton,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
