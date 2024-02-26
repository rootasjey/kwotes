import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

/// In validation quotes page header.
class ListPageHeader extends StatelessWidget {
  const ListPageHeader({
    super.key,
    required this.listId,
    required this.title,
    required this.accentColor,
    this.createMode = false,
    this.focusName = true,
    this.onCancelCreateMode,
    this.onDescriptionChanged,
    this.onEnterCreateMode,
    this.onNameChanged,
    this.onSave,
    this.description = "",
    this.nameController,
    this.descriptionController,
    this.descriptionHintText = "",
    this.isMobileSize = false,
  });

  /// Show inputs if true.
  final bool createMode;

  /// Will focus name input if true.
  final bool focusName;

  /// Adapt UI for mobile size.
  final bool isMobileSize;

  /// Accent color.
  final Color accentColor;

  /// Callback fired when list's name has changed.
  final void Function(String name)? onNameChanged;

  /// Callback fired when list's description has changed.
  final void Function(String description)? onDescriptionChanged;

  /// Callback fired to save changes (name and description).
  final void Function()? onSave;

  /// Callback fired to enter create mode and show inputs.
  final void Function(bool focusName)? onEnterCreateMode;

  /// Callback fired to exit create mode.
  final void Function()? onCancelCreateMode;

  /// List's id for hero animation.
  final String listId;

  /// Description hint text.
  final String descriptionHintText;

  /// List's title.
  final String title;

  /// List's description.
  final String description;

  /// Controller for name input.
  final TextEditingController? nameController;

  /// Controller for description input.
  final TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    if (createMode) {
      return Padding(
        padding: isMobileSize
            ? const EdgeInsets.only(left: 6.0, bottom: 0.0)
            : const EdgeInsets.only(left: 0.0, bottom: 42.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(
              widthFactor: isMobileSize ? 0.9 : 0.5,
              child: TextField(
                autofocus: focusName,
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                onChanged: onNameChanged,
                textInputAction: TextInputAction.next,
                style: Utils.calligraphy.title(
                  textStyle: TextStyle(
                    fontSize: isMobileSize ? 24.0 : 74.0,
                    fontWeight: FontWeight.w200,
                    height: 1.0,
                  ),
                ),
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: isMobileSize ? 0.9 : 0.5,
              child: TextField(
                autofocus: !focusName,
                controller: descriptionController,
                textCapitalization: TextCapitalization.words,
                onChanged: onDescriptionChanged,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => onSave?.call(),
                style: Utils.calligraphy.body2(
                  textStyle: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: foregroundColor?.withOpacity(0.4),
                    height: 1.0,
                  ),
                ),
                decoration: InputDecoration(
                  filled: false,
                  hintText: descriptionHintText,
                  fillColor: accentColor.withOpacity(0.1),
                  contentPadding: EdgeInsets.zero,
                  border: const UnderlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.start,
                children: [
                  TextButton(
                      onPressed: onCancelCreateMode,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        backgroundColor: Colors.black12,
                        foregroundColor:
                            Theme.of(context).textTheme.bodyMedium?.color,
                        textStyle: Utils.calligraphy.body4(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      child: Text(
                        "cancel".tr(),
                      )),
                  TextButton(
                    onPressed: onSave,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      backgroundColor: onSave != null ? accentColor : null,
                      foregroundColor: accentColor.computeLuminance() > 0.4
                          ? Colors.black87
                          : Colors.white,
                      textStyle: Utils.calligraphy.body4(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    child: Text(
                      "list.save.name".tr(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: listId,
          child: Material(
            color: Colors.transparent,
            child: TextButton(
              onPressed: () => onEnterCreateMode?.call(true),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 6.0, top: 0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: Text.rich(
                TextSpan(
                  text: title,
                  children: [
                    TextSpan(
                      text: ".",
                      style: TextStyle(
                        color: Constants.colors.inValidation,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                style: Utils.calligraphy.title(
                  textStyle: TextStyle(
                    fontSize: isMobileSize ? 74.0 : 124.0,
                    // fontSize: isMobileSize ? 36.0 : 74.0,
                    fontWeight: FontWeight.w200,
                    color: foregroundColor?.withOpacity(0.8),
                    shadows: [
                      Shadow(
                        blurRadius: 0.5,
                        offset: const Offset(-1.0, 1.0),
                        color: Constants.colors.inValidation,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (description.isNotEmpty)
          TextButton(
            onPressed: () => onEnterCreateMode?.call(false),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            child: Text(
              description,
              style: Utils.calligraphy.body2(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: foregroundColor?.withOpacity(0.4),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
