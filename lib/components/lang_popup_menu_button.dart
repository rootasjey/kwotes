import 'package:figstyle/state/colors.dart';
import 'package:figstyle/utils/language.dart';
import 'package:flutter/material.dart';

class LangPopupMenuButton extends StatelessWidget {
  final String lang;
  final Function(String) onLangChanged;

  const LangPopupMenuButton({
    Key key,
    @required this.lang,
    @required this.onLangChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
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
    );
  }
}
