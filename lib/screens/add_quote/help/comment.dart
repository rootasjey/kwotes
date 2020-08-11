import 'package:flutter/material.dart';
import 'package:memorare/screens/add_quote/help/utils.dart';

class HelpComment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 500.0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Text(
                'Help',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
          ),

          SizedBox(
            width: 500.0,
            child: Opacity(
              opacity: .6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextBlock(
                    text: 'Comment is optional',
                  ),

                  TextBlock(
                    text: 'Useful if you want to specify the context, the hidden meaning of the quote or something related',
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
