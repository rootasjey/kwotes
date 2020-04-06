import 'package:flutter/material.dart';
import 'package:memorare/router/router.dart';

class FullPageError extends StatelessWidget {
  final String message;

  FullPageError({
    this.message = 'An error occurred :(',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.warning,
            size: 50.0,
          ),

          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 40.0
            ),
            child: Opacity(
              opacity: .6,
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),

          FlatButton(
            onPressed: () {
              FluroRouter.router.pop(context);
            },
            child: Text(
              'Back',
            ),
          )
        ],
      ),
    );
  }
}
