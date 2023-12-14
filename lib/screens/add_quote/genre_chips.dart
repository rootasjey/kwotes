import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/expand_input_chip.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_main_genre.dart";
import "package:kwotes/types/reference_type.dart";

class GenreChips extends StatefulWidget {
  /// An input chip for selecting main genre of a reference.
  const GenreChips({
    super.key,
    this.show = false,
    this.margin = EdgeInsets.zero,
    this.onPrimaryGenreChanged,
    this.onSecondaryGenreChanged,
    this.primaryHintText,
    this.secondaryHintText,
    this.selectedPrimaryGenre = "",
    this.selectedSecondaryGenre = "",
  });

  /// Show this widget if true.
  final bool show;

  /// Margin to be applied on the chip relative to its parent.
  final EdgeInsets margin;

  /// Callback fired when main genre has changed.
  final void Function(String value)? onPrimaryGenreChanged;

  /// Callback fired when secondary genre has changed.
  final void Function(String value)? onSecondaryGenreChanged;

  /// Selected primary genre.
  final String selectedPrimaryGenre;

  /// Selected secondary genre.
  final String selectedSecondaryGenre;

  /// Hint text for the primary genre's input chip.
  final String? primaryHintText;

  /// Hint text for the seecondary genre's input chip.
  final String? secondaryHintText;

  @override
  State<GenreChips> createState() => _GenreChipsState();
}

class _GenreChipsState extends State<GenreChips> {
  /// Whether to show genre suggestions.
  bool _showGenreSuggestions = false;

  /// List of genres to be displayed.
  /// This list is possibly filtered based on the input text.
  List<EnumMainGenre> _genres = EnumMainGenre.values.sublist(0);

  /// Input text value.
  String _primaryGenreString = "";

  /// Input text controller for primary genre.
  final _primaryGenreTextController = TextEditingController();

  /// Input text controller for secondary genre.
  final _secondaryGenreTextController = TextEditingController();

  @override
  initState() {
    _primaryGenreString = widget.selectedPrimaryGenre;
    _primaryGenreTextController.text = _primaryGenreString.isEmpty
        ? ""
        : "genre.primary.$_primaryGenreString".tr();
    _secondaryGenreTextController.text = widget.selectedSecondaryGenre;
    super.initState();
  }

  @override
  dispose() {
    _primaryGenreTextController.dispose();
    _secondaryGenreTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return const SizedBox();
    }

    const double width = 160.0;

    final Brightness brightness = Theme.of(context).brightness;
    final BorderSide chipBorderSide = BorderSide(
      color: brightness == Brightness.light ? Colors.black12 : Colors.white24,
      width: 1.0,
    );

    final Color chipBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Padding(
      padding: widget.margin,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 0.0,
        children: [
          ExpandInputChip(
            open: true,
            width: width,
            hideCloseIcon: true,
            borderSide: chipBorderSide,
            backgroundColor: chipBackgroundColor,
            chipPadding: EdgeInsets.zero,
            textEditingController: _primaryGenreTextController,
            tooltip: "quote.add.reference.genre.primary".tr(),
            avatar: CircleAvatar(
              radius: 14.0,
              foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
              backgroundColor: Colors.transparent,
              child: Icon(
                Utils.graphic.getIconDataFromGenre(
                  ReferenceType.getGenreFromString(_primaryGenreString),
                ),
                size: 18.0,
              ),
            ),
            hintText: widget.primaryHintText,
            onTextChanged: onPrimaryGenreChanged,
            onFocusChanged: onPrimaryGenreFocusChanged,
            onSubmitted: onPrimaryGenreSubmitted,
          ),
          ExpandInputChip(
            open: true,
            width: width,
            hideCloseIcon: true,
            borderSide: chipBorderSide,
            chipPadding: EdgeInsets.zero,
            backgroundColor: chipBackgroundColor,
            textEditingController: _secondaryGenreTextController,
            tooltip: "quote.add.reference.genre.secondary".tr(),
            hintText: widget.secondaryHintText,
            onTextChanged: onSecondaryGenreChanged,
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
                      : chipBackgroundColor;

                  final Color? labelColor = highlight
                      ? backgroundColor.computeLuminance() > 0.4
                          ? Colors.black
                          : Colors.white
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      elevation: 2.0,
                      pressElevation: 0.0,
                      label: Text("genre.primary.${genre.name}".tr()),
                      backgroundColor: backgroundColor,
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

  /// Called when the secondary genre text input has changed.
  void onSecondaryGenreChanged(String value) {
    widget.onSecondaryGenreChanged?.call(value);
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
      _genres = EnumMainGenre.values
          .where(
            (EnumMainGenre genre) =>
                genre.name.contains(value.toLowerCase()) ||
                "genre.primary.${genre.name}"
                    .tr()
                    .toLowerCase()
                    .contains(value.toLowerCase()),
          )
          .toList();
    });
  }

  void onPrimaryGenreSubmitted(String value) {
    final EnumMainGenre genre = _genres.firstWhere(
      (x) =>
          x.name.toLowerCase().contains(value.toLowerCase()) ||
          "genre.primary.${x.name}"
              .tr()
              .toLowerCase()
              .contains(value.toLowerCase()),
      orElse: () => EnumMainGenre.other,
    );

    _primaryGenreString = genre.name;
    _primaryGenreTextController.text = "genre.primary.${genre.name}".tr();
    widget.onPrimaryGenreChanged?.call(genre.name);
  }
}
