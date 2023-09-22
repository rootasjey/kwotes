import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/texts/outlined_text_field.dart";

class NameInput extends StatelessWidget {
  const NameInput({
    super.key,
    this.accentColor = Colors.blue,
    this.hintText = "",
    this.onNameChanged,
    this.nameController,
  });

  /// Accent color.
  final MaterialColor accentColor;

  /// Callback fired when name input value has changed.
  final Function(String)? onNameChanged;

  /// Text hint.
  final String hintText;

  /// Controller for name input.
  final TextEditingController? nameController;

  @override
  Widget build(BuildContext context) {
    // String hintText = "list.create.hints.names.$randomInt".tr();
    // if (nameController != null && nameController.text.isNotEmpty) {
    //   hintText = nameController.text;
    // }

    return Padding(
      padding: const EdgeInsets.all(26.0),
      child: OutlinedTextField(
        accentColor: accentColor,
        label: "title".tr().toUpperCase(),
        controller: nameController,
        hintText: hintText.isNotEmpty ? hintText : nameController?.text ?? "",
        onChanged: onNameChanged,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
