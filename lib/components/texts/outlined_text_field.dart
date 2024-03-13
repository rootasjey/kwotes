import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class OutlinedTextField extends StatelessWidget {
  /// A TextField with a predefined outlined border.
  const OutlinedTextField({
    Key? key,
    this.accentColor = Colors.blue,
    this.label,
    this.controller,
    this.hintText = "",
    this.onChanged,
    this.onSubmitted,
    this.constraints = const BoxConstraints(maxHeight: 140.0),
    this.autofocus = true,
    this.maxLines = 1,
    this.textInputAction,
    this.keyboardType,
    this.focusNode,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.suffixIcon,
  }) : super(key: key);

  /// Will immediately request focus on mount if true.
  final bool autofocus;

  /// Will hide characters of true (usually for passwords).
  final bool obscureText;

  /// Accent color (of the border when focused).
  final Color accentColor;

  /// Limit this widget constrants.
  final BoxConstraints constraints;

  /// Allow to request focus.
  final FocusNode? focusNode;

  /// Maxium allowed lines.
  final int? maxLines;

  /// Fires when the user modify the input's value.
  final Function(String)? onChanged;

  /// Fires when the user send/validate the input's value.
  final Function(String)? onSubmitted;

  /// The [hintText] will be displayed inside the input.
  final String hintText;

  /// The label will be displayed on top of the input.
  final String? label;

  /// How to capitalize this text input.
  final TextCapitalization textCapitalization;

  /// A controller to manipulate the input component.
  final TextEditingController? controller;

  /// Associated keyboard to this input (on mobile).
  final TextInputAction? textInputAction;

  /// Adapt mobile keyboard to this input (sentences, email, ...).
  final TextInputType? keyboardType;

  /// Icon to display at the end of the input.
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color fillColor =
        brightness == Brightness.light ? Colors.white70 : Colors.black38;

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final BorderRadius borderRadius = BorderRadius.circular(4.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: constraints,
          child: TextField(
            focusNode: focusNode,
            autofocus: autofocus,
            controller: controller,
            maxLines: maxLines,
            obscureText: obscureText,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            cursorColor: accentColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              hintText: hintText,
              suffixIcon: suffixIcon,
              labelText: label,
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor?.withOpacity(0.6),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: maxLines == null ? 8.0 : 0.0,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: Constants.colors.error,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: accentColor,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: accentColor,
                  width: 2.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
