import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';

class ErrorContainer extends StatelessWidget {
  final String message;

  ErrorContainer({this.message = 'Oops! There was an error'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Icon(Icons.sentiment_neutral, size: 40.0),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),

          FlatButton(
            onPressed: () {},
            shape: RoundedRectangleBorder(
              side: BorderSide(color: stateColors.primary),
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: null,
          ),
        ],
      )
    );
  }
}
