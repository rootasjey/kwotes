import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_header.dart";
import "package:kwotes/components/dialogs/input/input_dialog.dart";
import "package:kwotes/components/texts/outlined_text_field.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
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
    this.onNameListChanged,
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

  /// Callback fired when the name has changed.
  final void Function(String name)? onNameListChanged;

  /// Scroll controller.
  final ScrollController? pageScrollController;

  /// Controller for name input.
  final TextEditingController? nameController;

  /// Controller for description input.
  final TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final String nameValue = nameController?.text ?? "";
    final void Function()? onConditionalValidate =
        nameValue.isNotEmpty ? onValidate : null;

    final Color borderColor = accentColor ?? Constants.colors.primary;

    if (asBottomSheet) {
      return Container(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
        ),
        child: ListView(
          controller: pageScrollController,
          children: [
            AddToListHeader(
              create: true,
              margin: const EdgeInsets.only(bottom: 24.0),
              onBack: onTapBackButton,
              showCreateListButton: false,
            ),
            OutlinedTextField(
              accentColor: accentColor ?? Constants.colors.primary,
              controller: nameController,
              label: "name".tr(),
              hintText: "list.create.hints.names.$randomHintNumber".tr(),
              textInputAction: TextInputAction.next,
              onChanged: onNameListChanged,
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
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onValidate?.call(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
              ),
              child: ElevatedButton.icon(
                onPressed: onConditionalValidate,
                icon: const Icon(TablerIcons.hammer, size: 18.0),
                label: Text(
                  "list.create.name".tr(),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: accentColor,
                  disabledBackgroundColor: isDark ? Colors.grey.shade900 : null,
                  textStyle: Utils.calligraphy.body(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: onConditionalValidate != null
                          ? borderColor
                          : Colors.black12,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            if (nameValue.isEmpty)
              Text(
                "list.create.not_empty".tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 12.0,
                    color: foregroundColor?.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
      accentColor: materialAccentColor,
      descriptionController: descriptionController,
      nameController: nameController,
      onCancel: () => onCancel?.call(),
      onSubmitted: (_) => onConditionalValidate?.call(),
      titleValue: "list.create.name".tr(),
      submitButtonValue: "list.create.validate".tr(),
      subtitleValue: "list.create.description".tr(),
    );
  }
}
