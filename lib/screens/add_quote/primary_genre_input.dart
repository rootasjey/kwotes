import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_main_genre.dart";
import "package:kwotes/types/reference_type.dart";

class PrimaryGenreInput extends StatefulWidget {
  /// Reference primary genre input.
  const PrimaryGenreInput({
    super.key,
    required this.selectedPrimaryGenre,
    this.margin = EdgeInsets.zero,
    this.onPrimaryGenreChanged,
    this.primaryHintText,
  });

  /// Margin to be applied on the chip relative to its parent.
  final EdgeInsets margin;

  /// Callback fired when main genre has changed.
  final void Function(String value)? onPrimaryGenreChanged;

  /// Selected primary genre.
  final String selectedPrimaryGenre;

  /// Hint text for the primary genre's input chip.
  final String? primaryHintText;

  @override
  State<PrimaryGenreInput> createState() => _PrimaryGenreInputState();
}

class _PrimaryGenreInputState extends State<PrimaryGenreInput> {
  /// Whether to show genre suggestions.
  bool _showGenreSuggestions = false;

  /// Focus node for input text field.
  final FocusNode _inputFocusNode = FocusNode();

  /// List of genres to be displayed.
  /// This list is possibly filtered based on the input text.
  List<EnumMainGenre> _genres = EnumMainGenre.values.sublist(0);

  /// Input text value.
  String _primaryGenreString = "";

  /// Input text controller for primary genre.
  final _primaryGenreTextController = TextEditingController();

  @override
  initState() {
    super.initState();
    _primaryGenreString = widget.selectedPrimaryGenre;
    _primaryGenreTextController.text = _primaryGenreString.isEmpty
        ? ""
        : "genre.primary.$_primaryGenreString".tr();
    _inputFocusNode.addListener(onInputFocusChanged);
  }

  @override
  dispose() {
    _primaryGenreTextController.dispose();
    _inputFocusNode.removeListener(onInputFocusChanged);
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return Padding(
      padding: widget.margin,
      child: Wrap(
        spacing: 12.0,
        runSpacing: 0.0,
        children: [
          TextFormField(
            controller: _primaryGenreTextController,
            onChanged: onPrimaryGenreChanged,
            onFieldSubmitted: onPrimaryGenreSubmitted,
            focusNode: _inputFocusNode,
            decoration: InputDecoration(
              iconColor: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.5),
              icon: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  Utils.graphic.getIconDataFromGenre(
                    ReferenceType.getGenreFromString(_primaryGenreString),
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              isDense: true,
              hintText: widget.primaryHintText,
            ),
          ),
          Opacity(
            opacity: _showGenreSuggestions ? 1.0 : 0.0,
            child: AnimatedContainer(
              height: _showGenreSuggestions ? 62.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.decelerate,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final EnumMainGenre genre = _genres[index];
                  final bool highlight =
                      index == 0 && _primaryGenreTextController.text.isNotEmpty;

                  final Color backgroundColor = highlight
                      ? Constants.colors.foregroundPalette.first
                      : scaffoldColor;

                  final Color? labelColor = highlight
                      ? backgroundColor.computeLuminance() > 0.4
                          ? Colors.black
                          : Colors.white
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      elevation: 1.0,
                      pressElevation: 0.0,
                      label: Text("genre.primary.${genre.name}".tr()),
                      backgroundColor: backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withGreen(213),
                          width: 1.2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      labelStyle: TextStyle(
                        color: labelColor,
                      ),
                      onPressed: () => onPrimaryGenreChipTapped(genre),
                    ),
                  );
                },
                itemCount: _genres.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Called when primary genre text input focus has changed.
  void onPrimaryGenreFocusChanged(bool hasFocus) {
    setState(() {
      _showGenreSuggestions = hasFocus;
    });
  }

  /// Called when the primary genre text input has changed.
  void onPrimaryGenreChanged(String value) {
    _primaryGenreString = value;
    updateGenreSuggestions(value);
    widget.onPrimaryGenreChanged?.call(value);
  }

  /// Called when a (primary genre) chip is tapped.
  void onPrimaryGenreChipTapped(EnumMainGenre genre) {
    _primaryGenreString = genre.name;
    _primaryGenreTextController.text = "genre.primary.${genre.name}".tr();
    widget.onPrimaryGenreChanged?.call(genre.name);
  }

  /// Update suggestions list based on the input.
  void updateGenreSuggestions(String value) {
    if (value.isEmpty) {
      setState(() {
        _genres
          ..clear()
          ..addAll(EnumMainGenre.values);
      });
      return;
    }

    setState(() {
      _genres = EnumMainGenre.values.where((EnumMainGenre genre) {
        return genre.name.contains(value.toLowerCase()) ||
            "genre.primary.${genre.name}"
                .tr()
                .toLowerCase()
                .contains(value.toLowerCase());
      }).toList();
    });
  }

  void onPrimaryGenreSubmitted(String value) {
    final EnumMainGenre genre = _genres.firstWhere(
      (EnumMainGenre x) {
        return x.name.toLowerCase().contains(value.toLowerCase()) ||
            "genre.primary.${x.name}"
                .tr()
                .toLowerCase()
                .contains(value.toLowerCase());
      },
      orElse: () => EnumMainGenre.other,
    );

    _primaryGenreString = genre.name;
    _primaryGenreTextController.text = "genre.primary.${genre.name}".tr();
    widget.onPrimaryGenreChanged?.call(genre.name);
  }

  /// Callback fired when the focus has changed.
  void onInputFocusChanged() {
    onPrimaryGenreFocusChanged.call(_inputFocusNode.hasFocus);
  }
}
