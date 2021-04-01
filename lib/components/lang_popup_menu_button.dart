import 'package:fig_style/state/colors.dart';
import 'package:fig_style/utils/language.dart';
import 'package:flutter/material.dart';

class LangPopupMenuButton extends StatelessWidget {
  final String lang;
  final Function(String) onLangChanged;
  final double opacity;
  final EdgeInsets padding;
  final double elevation;

  const LangPopupMenuButton({
    Key key,
    @required this.lang,
    @required this.onLangChanged,
    this.elevation = 0.0,
    this.opacity = 1.0,
    this.padding = const EdgeInsets.only(top: 2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Material(
        elevation: elevation,
        child: Opacity(
          opacity: opacity,
          child: PopupMenuButton<String>(
            tooltip: "Change language",
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                lang.toUpperCase(),
                style: TextStyle(
                  color: stateColors.foreground,
                  fontSize: 16.0,
                ),
              ),
            ),
            onSelected: onLangChanged,
            itemBuilder: (context) => Language.available()
                .map(
                  (value) => PopupMenuItem(
                    value: value,
                    child: Text(value.toUpperCase()),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
