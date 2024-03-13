import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/cancel_button.dart";

class SimpleAddQuoteAuthor extends StatelessWidget {
  /// Widget to add an author to a quote in a minimal way.
  const SimpleAddQuoteAuthor({
    super.key,
    required this.nameController,
    required this.authorNameFocusNode,
    this.onNameChanged,
    this.isMobileSize = false,
    this.boxConstraints = const BoxConstraints(),
    this.margin = EdgeInsets.zero,
    this.randomAuthorInt = 0,
    this.onTapCancelButtonName,
    this.cancelAuthorNameFocusNode,
    this.authorNameErrorText,
  });

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Constraints for this widget.
  final BoxConstraints boxConstraints;

  /// Random int used to select a random author hint
  /// (int value must be between 0 to 9).
  final int randomAuthorInt;

  /// Margin around this widget.
  final EdgeInsets margin;

  /// Used to request focus on the name input and to show cancel button.
  final FocusNode authorNameFocusNode;

  /// Cancel button focus node to deactivate focus.
  final FocusNode? cancelAuthorNameFocusNode;

  /// Text editing controller for author name.
  final TextEditingController nameController;

  /// Callback fired when author's name has changed.
  final void Function(String newValue)? onNameChanged;

  /// Callback fired when cancel button is pressed.
  final void Function()? onTapCancelButtonName;

  /// Error text for author name.
  final String? authorNameErrorText;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color accentColor = Theme.of(context).primaryColor;
    const double borderWidth = 1.0;
    const double borderWidthFocusFactor = 1.4;
    // const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8.0));
    const BorderRadius nameBorderRadius = BorderRadius.all(
      Radius.circular(24.0),
    );
    final Color nameBorderColor =
        Theme.of(context).dividerColor.withOpacity(0.1);

    return SliverPadding(
      padding: margin,
      sliver: SliverToBoxAdapter(
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: boxConstraints,
            child: TextFormField(
              maxLines: null,
              autofocus: false,
              focusNode: authorNameFocusNode,
              onChanged: onNameChanged,
              controller: nameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              style: Utils.calligraphy.title(
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
              decoration: InputDecoration(
                isDense: true,
                labelText: "author.optional".tr(),
                labelStyle: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: foregroundColor?.withOpacity(0.6),
                  ),
                ),
                suffixIcon: CancelButton(
                  focusNode: cancelAuthorNameFocusNode,
                  show: authorNameFocusNode.hasFocus,
                  textStyle: const TextStyle(fontSize: 14.0),
                  onTapCancelButton: onTapCancelButtonName,
                  buttonStyle: TextButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                ),
                contentPadding: const EdgeInsets.all(12.0),
                errorText: authorNameErrorText,
                hintText: "quote.add.author.names.$randomAuthorInt".tr(),
                hintMaxLines: null,
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
                    width: borderWidth * borderWidthFocusFactor,
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
