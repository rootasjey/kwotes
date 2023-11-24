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
    this.accentColor,
    this.buttonBackgroundColor,
    this.quotes = const [],
    this.onCancel,
    this.onValidate,
    this.nameController,
    this.descriptionController,
    this.onTapBackButton,
    this.randomHintNumber = 0,
    this.pageScrollController,
  });

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Accent color.
  final Color? accentColor;

  /// Button background color.
  final Color? buttonBackgroundColor;

  /// A number between 0 and 9 to select a random hint.
  final int randomHintNumber;

  /// List of quotes to add to a list.
  final List<Quote> quotes;

  /// Trigger when the user tap on cancel button.
  final void Function()? onCancel;

  /// Trigger when the user tap on back button.
  final void Function()? onTapBackButton;

  /// Trigger when the user tap on validation button.
  final void Function()? onValidate;

  /// Scroll controller.
  final ScrollController? pageScrollController;

  /// Controller for name input.
  final TextEditingController? nameController;

  /// Controller for description input.
  final TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    if (asBottomSheet) {
      return Container(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
        ),
        child: ListView(
          controller: pageScrollController,
          children: [
            AddToListHeader(
              create: true,
              margin: const EdgeInsets.only(bottom: 24.0),
              onBack: onTapBackButton,
            ),
            OutlinedTextField(
              accentColor: accentColor ?? Constants.colors.primary,
              controller: nameController,
              label: "name".tr(),
              hintText: "list.create.hints.names.$randomHintNumber".tr(),
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: OutlinedTextField(
                accentColor: accentColor ?? Constants.colors.primary,
                autofocus: false,
                controller: descriptionController,
                label: "description.name".tr(),
                hintText:
                    "list.create.hints.descriptions.$randomHintNumber".tr(),
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onValidate?.call(),
              ),
            ),
            ColoredTextButton(
              textValue: "list.create.name".tr(),
              onPressed: onValidate,
              textAlign: TextAlign.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              style: TextButton.styleFrom(
                  backgroundColor: accentColor?.withOpacity(0.6)),
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
      );
    }

    final MaterialColor materialAccentColor = Constants.colors
        .createMaterialColorFrom(accentColor ?? Constants.colors.primary);

    return InputDialog(
      // accentColor: Colors.indigo,
      accentColor: materialAccentColor,
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
