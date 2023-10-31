import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";

class SecondaryGenreInput extends StatelessWidget {
  const SecondaryGenreInput({
    super.key,
    required this.selectedSecondaryGenre,
    this.margin = EdgeInsets.zero,
    this.onSecondaryGenreChanged,
    this.secondaryHintText,
  });

  /// Margin to be applied on the chip relative to its parent.
  final EdgeInsets margin;

  /// Callback fired when secondary genre has changed.
  final void Function(String value)? onSecondaryGenreChanged;

  /// Selected secondary genre.
  final String selectedSecondaryGenre;

  /// Hint text for the secondary genre's input chip.
  final String? secondaryHintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // width: width,
      // hideCloseIcon: true,
      // borderSide: chipBorderSide,
      // backgroundColor: chipBackgroundColor,
      // textEditingController: _secondaryGenreTextController,
      // tooltip: "quote.add.reference.genre.secondary".tr(),
      // hintText: widget.secondaryHintText,
      onChanged: onSecondaryGenreChanged,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.only(
          top: 12.0,
          bottom: 12.0,
        ),
        icon: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Icon(TablerIcons.hexagon),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        isDense: true,
        hintText: secondaryHintText,
      ),
    );
  }
}
