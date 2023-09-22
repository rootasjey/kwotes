import "dart:math";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/buttons/dark_elevated_button.dart";
import "package:kwotes/components/dialogs/input/description_input.dart";
import "package:kwotes/components/dialogs/input/footer_buttons.dart";
import "package:kwotes/components/dialogs/input/name_input.dart";
import "package:kwotes/components/dialogs/title_dialog.dart";
import "package:kwotes/components/texts/outlined_text_field.dart";
import "package:kwotes/globals/constants.dart";

/// A dialog which has one or multiple inputs.
class InputDialog extends StatelessWidget {
  const InputDialog({
    Key? key,
    required this.onCancel,
    required this.onSubmitted,
    required this.subtitleValue,
    required this.titleValue,
    this.asBottomSheet = false,
    this.descriptionController,
    this.nameController,
    this.onNameChanged,
    this.onDescriptionChanged,
    this.submitButtonValue = "",
    this.accentColor = Colors.blue,
  }) : super(key: key);

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Accent color.
  final MaterialColor accentColor;

  /// Callback fired when name input value has changed.
  final void Function(String)? onNameChanged;

  /// Callback fired when description input value has changed.
  final void Function(String)? onDescriptionChanged;

  /// Callback fired when we validate inputs.
  final void Function(String) onSubmitted;

  /// Callback fired when we cancel and close the inputs.
  final void Function() onCancel;

  /// Text value for the submit button.
  final String submitButtonValue;

  /// Title value.
  final String titleValue;

  /// Subtitle value.
  final String subtitleValue;

  /// Controller for name input.
  final TextEditingController? nameController;

  /// Controller for description input.
  final TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    final int randomInt = Random().nextInt(9);
    String nameHintText = "list.create.hints.names.$randomInt".tr();
    String descriptionHintText =
        "list.create.hints.descriptions.$randomInt".tr();

    if (asBottomSheet) {
      return Material(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleDialog(
                accentColor: accentColor,
                titleValue: titleValue,
                subtitleValue: subtitleValue,
                onCancel: onCancel,
              ),
              NameInput(
                accentColor: accentColor,
                hintText: nameHintText,
                onNameChanged: onNameChanged,
                nameController: nameController,
              ),
              DescriptionInput(
                accentColor: accentColor,
                hintText: descriptionHintText,
                onDescriptionChanged: onDescriptionChanged,
                descriptionController: descriptionController,
                onSubmitted: onSubmitted,
              ),
              FooterButtons(
                accentColor: accentColor,
                onSubmitted: onSubmitted,
                submitButtonValue: submitButtonValue,
                nameController: nameController,
              ),
            ],
          ),
        ),
      );
    }

    return SimpleDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: TitleDialog(
        accentColor: accentColor,
        titleValue: titleValue,
        subtitleValue: subtitleValue,
        onCancel: onCancel,
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16.0),
      children: [
        NameInput(
          accentColor: accentColor,
          hintText: nameHintText,
          onNameChanged: onNameChanged,
          nameController: nameController,
        ),
        DescriptionInput(
          accentColor: accentColor,
          hintText: descriptionHintText,
          onDescriptionChanged: onDescriptionChanged,
          descriptionController: descriptionController,
          onSubmitted: onSubmitted,
        ),
        FooterButtons(
          accentColor: accentColor,
          onSubmitted: onSubmitted,
          submitButtonValue: submitButtonValue,
          nameController: nameController,
        ),
      ],
    );
  }

  static Widget singleInput({
    final Key? key,
    required final String titleValue,
    required final String subtitleValue,
    required final void Function() onCancel,
    final bool validateOnEnter = true,
    final void Function(String)? onNameChanged,
    final void Function(String)? onSubmitted,
    final int? maxLines = 1,
    final String submitButtonValue = "",
    final String? label,
    String? hintText,
    final TextEditingController? nameController,
    final TextInputAction? textInputAction,
  }) {
    if (hintText == null &&
        nameController != null &&
        nameController.text.isNotEmpty) {
      hintText = nameController.text;
    }

    if (hintText == null) {
      final String generatedHintText =
          "book_create_hint_texts.${Random().nextInt(9)}".tr();
      hintText = generatedHintText;
    }

    final String buttonTextValue =
        submitButtonValue.isNotEmpty ? submitButtonValue : "create".tr();

    String textfieldValue = "";

    return SimpleDialog(
      key: key,
      backgroundColor: Constants.colors.clairPink,
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400.0),
        child: TitleDialog(
          titleValue: titleValue,
          subtitleValue: subtitleValue,
          onCancel: onCancel,
        ),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16.0),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400.0),
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: OutlinedTextField(
              label: label,
              controller: nameController,
              hintText: hintText,
              onChanged: (String value) {
                textfieldValue = value;
                onNameChanged?.call(value);
              },
              maxLines: maxLines,
              textInputAction: textInputAction,
              onSubmitted: validateOnEnter ? onSubmitted : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: DarkElevatedButton.large(
            onPressed: () {
              onSubmitted?.call(textfieldValue);
            },
            child: Text(buttonTextValue),
          ),
        ),
      ],
    );
  }
}
