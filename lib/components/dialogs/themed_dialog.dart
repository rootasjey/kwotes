import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/buttons/dark_elevated_button.dart";
import "package:kwotes/components/buttons/dot_close_button.dart";
import "package:kwotes/components/dialogs/title_dialog.dart";
import "package:kwotes/components/validation_shortcuts.dart";
import "package:kwotes/globals/constants.dart";

/// A dialog with the theme of the app.
class ThemedDialog extends StatelessWidget {
  const ThemedDialog({
    Key? key,
    required this.body,
    required this.onCancel,
    this.onValidate,
    this.title,
    this.focusNode,
    this.centerTitle = true,
    this.spaceActive = true,
    this.autofocus = true,
    this.textButtonValidation = "",
    this.titleValue = "",
    this.subtitleValue = "",
    this.showDivider = false,
    this.useRawDialog = false,
    this.height = 600.0,
    this.width = 500.0,
    this.footer,
  }) : super(key: key);

  /// Show a divider below the header if true.
  final bool showDivider;

  /// If true, this widget will use [Dialog] as a basis
  /// instead of [SimpleDialog]. It's necessary if you implement
  /// your own scrolling mecanism.
  final bool useRawDialog;

  /// Dialog's width. Used only when [useRawDialog] is true.
  final double width;

  /// Dialog's height. Used only when [useRawDialog] is true.
  final double height;

  /// Trigger when the user tap on close button
  /// or fires keyboard shortcuts for closing the dialog.
  final Function() onCancel;

  /// Trigger when the user tap on validation button
  /// or fires keyboard shortcuts for validating the dialog.
  final Function()? onValidate;

  /// Supply a [focusNode] parameter to force focus request
  /// if it doesn't automatically works.
  final FocusNode? focusNode;

  /// Will be displayed on validation button.
  final String textButtonValidation;

  /// Dialog's title.
  final Widget? title;

  /// Dialog body. Can be a [SingleChildScrollView] for example.
  final Widget body;

  /// If set, this widget will replace the default footer.
  final Widget? footer;

  /// If true, center dialog's title.
  final bool centerTitle;

  /// If true, space bar will submit this dialog (as well as 'enter').
  final bool spaceActive;

  /// If true, this dialog will try to request focus on load.
  final bool autofocus;

  /// Title as string.
  final String titleValue;

  /// Subtitle as string.
  final String subtitleValue;

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Container();

    if (title != null) {
      titleWidget = titleContainer(
        context,
        color: Constants.colors.foregroundPalette.first,
      );
    } else {
      titleWidget = TitleDialog(
        titleValue: titleValue,
        subtitleValue: subtitleValue,
        onCancel: onCancel,
      );
    }

    Widget footerWidget = Container();

    if (footer != null) {
      footerWidget = footer as Widget;
    } else {
      footerWidget = Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: footerButtons(),
      );
    }

    if (useRawDialog) {
      return ValidationShortcuts(
        autofocus: autofocus,
        focusNode: focusNode,
        onCancel: onCancel,
        onValidate: onValidate,
        spaceActive: spaceActive,
        child: Dialog(
          insetPadding: const EdgeInsets.all(60.0),
          alignment: Alignment.center,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
                titleWidget,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: body,
                ),
                if (showDivider) const Divider(),
                footerWidget,
              ],
            ),
          ),
        ),
      );
    }

    return ValidationShortcuts(
      autofocus: autofocus,
      focusNode: focusNode,
      onCancel: onCancel,
      onValidate: onValidate,
      spaceActive: spaceActive,
      child: SimpleDialog(
        backgroundColor: Constants.colors.clairPink,
        title: titleWidget,
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(2.0),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 16.0,
              right: 16.0,
            ),
            child: body,
          ),
          if (showDivider) const Divider(),
          footerWidget,
        ],
      ),
    );
  }

  Widget closeButton() {
    return Positioned(
      top: 12.0,
      left: 12.0,
      child: DotCloseButton(
        tooltip: "cancel".tr(),
        onTap: onCancel,
      ),
    );
  }

  Widget footerButtons() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: DarkElevatedButton.large(
            onPressed: onValidate,
            child: Text(textButtonValidation),
          ),
        ),
      ],
    );
  }

  Widget titleContainer(BuildContext context, {required Color color}) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          closeButton(),
          Column(
            crossAxisAlignment: centerTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                  left: 32.0,
                  right: 24.0,
                ),
                child: title,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Divider(
                  thickness: 1.5,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
