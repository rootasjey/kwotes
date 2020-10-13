import 'package:flutter/material.dart';
import 'package:memorare/screens/add_quote/help/utils.dart';

class HelpContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(40.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 500.0,
            child: Opacity(
              opacity: .6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextBlock(
                    text:
                        "Only the quote's content and a topic are required for submission.",
                  ),
                  TextBlock(
                    text:
                        'Quotes with an author or a reference are preferred. A reference can be a movie, a book, a song, a game or from any cultural material.',
                  ),
                  TextBlock(
                    text:
                        'The moderators can reject, remove or modify your quotes without notice, before or after validation.',
                  ),
                  TextBlock(
                    text:
                        'Explicit, offensive and disrespectful words and ideas can be rejected.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
