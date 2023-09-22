import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/texts/outlined_text_field.dart";

class DescriptionInput extends StatelessWidget {
  const DescriptionInput({
    super.key,
    this.accentColor = Colors.blue,
    this.descriptionController,
    this.hintText = "",
    this.onDescriptionChanged,
    this.onSubmitted,
  });

  /// Accent color.
  final MaterialColor accentColor;

  /// Callback fired when description input value has changed.
  final void Function(String value)? onDescriptionChanged;

  /// Callback fired when the user taps the enter key.
  final void Function(String value)? onSubmitted;

  /// Text hint.
  final String hintText;

  /// Controller for description input.
  final TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    // String hintText = "list.create.hints.descriptions.$randomInt".tr();

    // if (descriptionController != null &&
    //     descriptionController!.text.isNotEmpty) {
    //   hintText = descriptionController!.text;
    // }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
      ),
      child: OutlinedTextField(
        accentColor: accentColor,
        label: "description.optional".tr().toUpperCase(),
        controller: descriptionController,
        hintText: hintText,
        onChanged: onDescriptionChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
