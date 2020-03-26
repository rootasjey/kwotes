import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';

class AddQuoteNavButtons extends StatelessWidget {
  final String prevMessage;
  final String nextMessage;

  final Function onPrevPressed;
  final Function onNextPressed;

  AddQuoteNavButtons({
    this.nextMessage = 'Next',
    this.prevMessage = 'Previous',
    this.onNextPressed,
    this.onPrevPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, bottom: 300.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FlatButton(
              onPressed: onPrevPressed,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: stateColors.foreground,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  prevMessage,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FlatButton(
              onPressed: onNextPressed,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: stateColors.primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  nextMessage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
