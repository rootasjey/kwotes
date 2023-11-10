import "dart:math";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_header.dart";
import "package:kwotes/components/dialogs/input/input_dialog.dart";
import "package:kwotes/components/texts/outlined_text_field.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/types/quote.dart";

class CreateListDialog extends StatelessWidget {
  /// Scaffold component to create a new list in [AddToListDialog].
  const CreateListDialog({
    super.key,
    this.asBottomSheet = false,
    this.quotes = const [],
    this.onCancel,
    this.onValidate,
    this.nameController,
    this.descriptionController,
  });

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// List of quotes to add to a list.
  final List<Quote> quotes;

  /// Trigger when the user tap on cancel button.
  final void Function()? onCancel;

  /// Trigger when the user tap on validation button.
  final void Function()? onValidate;

  /// Controller for name input.
  final TextEditingController? nameController;

  /// Controller for description input.
  final TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    final Color buttonBackgroundColor = Constants.colors.getRandomPastel();
    // final Color buttonBackgroundColor = Theme.of(context).primaryColor;

    if (asBottomSheet) {
      return Material(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 24.0,
              left: 12.0,
              right: 12.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AddToListHeader(
                  create: true,
                  margin: EdgeInsets.only(bottom: 24.0),
                ),
                OutlinedTextField(
                  controller: nameController,
                  label: "name".tr(),
                  hintText:
                      "list.create.hints.names.${Random().nextInt(9)}".tr(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: OutlinedTextField(
                    autofocus: false,
                    controller: descriptionController,
                    label: "description.name".tr(),
                    hintText:
                        "list.create.hints.descriptions.${Random().nextInt(9)}"
                            .tr(),
                  ),
                ),
                ColoredTextButton(
                  textValue: "list.create.name".tr(),
                  onPressed: onValidate,
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: buttonBackgroundColor,
                  ),
                  margin: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                ),
              ]
                  .animate(interval: 25.ms)
                  .slideY(
                    begin: 0.8,
                    end: 0.0,
                    duration: 150.ms,
                    curve: Curves.decelerate,
                  )
                  .fadeIn(),
            ),
          ),
        ),
      );
    }

    return InputDialog(
      accentColor: Colors.indigo,
      descriptionController: descriptionController,
      nameController: nameController,
      onCancel: () => onCancel?.call(),
      onSubmitted: (_) => onValidate?.call(),
      titleValue: "list.create.name".tr(),
      submitButtonValue: "list.create.validate".tr(),
      subtitleValue: "list.create.description".tr(),
    );
  }
}
