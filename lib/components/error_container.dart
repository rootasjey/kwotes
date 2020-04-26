import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';

class ErrorContainer extends StatelessWidget {
  final String message;
  final Function onPressed;

  ErrorContainer({
    this.onPressed,
    this.message = 'Oops! There was an error.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          Icon(Icons.sentiment_neutral, size: 40.0),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60.0),
            child: Opacity(
              opacity: .8,
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),

          FlatButton(
            onPressed: onPressed,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: stateColors.primary),
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
