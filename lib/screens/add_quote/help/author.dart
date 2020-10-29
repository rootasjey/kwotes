import 'package:flutter/material.dart';
import 'package:figstyle/screens/add_quote/help/utils.dart';

class HelpAuthor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 500.0,
          child: Opacity(
            opacity: .6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextBlock(
                  text: 'Author information are optional.',
                ),
                TextBlock(
                  text:
                      "If you select the author's name in the dropdown list, other fields can stay empty.",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
