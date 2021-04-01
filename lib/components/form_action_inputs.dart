import 'package:fig_style/state/colors.dart';
import 'package:fig_style/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// Use as a form footer to cancel of validate data.
class FormActionInputs extends StatelessWidget {
  /// Executed when the form is closed with the cancel button.
  final VoidCallback onCancel;

  /// Executed when the form is closed with validate button.
  final VoidCallback onValidate;

  /// Cancel button's text string value.
  final String cancelTextString;

  /// Padding around the buttons.
  final EdgeInsets padding;

  /// Automatically adjust padding according to app's widget.
  final bool adaptivePadding;

  const FormActionInputs({
    Key key,
    this.onCancel,
    this.onValidate,
    this.cancelTextString = 'Clear input',
    this.padding = const EdgeInsets.only(
      top: 20.0,
    ),
    this.adaptivePadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double left = 40.0;
    double spacing = 24.0;

    EdgeInsets _padding = padding;
    final isSmall =
        MediaQuery.of(context).size.width < Constants.maxMobileWidth;

    if (adaptivePadding && isSmall) {
      spacing = 12.0;
      left = 0.0;

      _padding = EdgeInsets.only(
        top: 20.0,
        left: left,
      );
    }

    return Padding(
      padding: _padding,
      child: Wrap(
        spacing: spacing,
        runSpacing: 10.0,
        children: [
          Opacity(
            opacity: 0.6,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: Icon(UniconsLine.times),
              label: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 12.0,
                ),
                child: Text(
                  cancelTextString,
                ),
              ),
              style: OutlinedButton.styleFrom(
                primary: stateColors.foreground,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (onValidate != null) {
                onValidate();
              }

              Navigator.of(context).pop();
            },
            icon: Icon(UniconsLine.check),
            label: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ),
              child: Text(
                "Save",
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: stateColors.validation,
            ),
          ),
        ],
      ),
    );
  }
}
