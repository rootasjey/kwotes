import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/cancel_button.dart";

class SimpleAddQuoteReference extends StatelessWidget {
  /// Widget to add a reference to a quote in a minimal way.
  const SimpleAddQuoteReference({
    super.key,
    required this.nameFocusNode,
    required this.nameController,
    this.isMobileSize = false,
    this.boxConstraints = const BoxConstraints(),
    this.onNameChanged,
    this.onTapCancelButtonName,
    this.referenceNameErrorText,
    this.randomReferenceInt = 0,
    this.margin = EdgeInsets.zero,
    this.cancelReferenceNameFocusNode,
    this.onSubmitted,
  });

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Constraints for this widget.
  final BoxConstraints boxConstraints;

  /// Random int used to select a random reference (hint).
  final int randomReferenceInt;

  /// Margin around this widget.
  final EdgeInsets margin;

  /// Used to request focus on the name input and to show cancel button.
  final FocusNode nameFocusNode;

  /// Cancel button focus node to deactivate focus.
  final FocusNode? cancelReferenceNameFocusNode;

  /// Text editing controller for reference name.
  final TextEditingController nameController;

  /// Callback fired when reference's name has changed.
  final void Function(String newValue)? onNameChanged;

  /// Callback fired when cancel button is pressed.
  final void Function()? onTapCancelButtonName;

  /// Callback fired when reference name is submitted.
  final void Function(String value)? onSubmitted;

  /// Error text for reference name.
  final String? referenceNameErrorText;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color accentColor = Theme.of(context).primaryColor;

    const double borderWidth = 1.0;
    const BorderRadius nameBorderRadius =
        BorderRadius.all(Radius.circular(24.0));
    final Color nameBorderColor =
        Theme.of(context).dividerColor.withOpacity(0.1);

    return SliverPadding(
      padding: margin,
      sliver: SliverToBoxAdapter(
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: boxConstraints,
            child: TextField(
              maxLines: null,
              autofocus: false,
              controller: nameController,
              focusNode: nameFocusNode,
              onChanged: onNameChanged,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              onSubmitted: onSubmitted,
              style: Utils.calligraphy.title(
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
              decoration: InputDecoration(
                isDense: true,
                labelText: "reference.optional".tr(),
                labelStyle: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: foregroundColor?.withOpacity(0.6),
                  ),
                ),
                suffixIcon: CancelButton(
                  focusNode: cancelReferenceNameFocusNode,
                  onTapCancelButton: onTapCancelButtonName,
                  show: nameFocusNode.hasFocus,
                  textStyle: const TextStyle(fontSize: 14.0),
                ),
                contentPadding: const EdgeInsets.all(12.0),
                errorText: referenceNameErrorText,
                hintText: "quote.add.reference.names.$randomReferenceInt".tr(),
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
                    width: borderWidth,
                    color: accentColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
