import 'package:flutter/material.dart';
import 'package:figstyle/screens/add_quote/help/utils.dart';

class HelpComment extends StatelessWidget {
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
                  text: 'Comment is optional.',
                ),
                TextBlock(
                  text:
                      'Useful if you want to specify the context, the hidden meaning of the quote or something related.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
