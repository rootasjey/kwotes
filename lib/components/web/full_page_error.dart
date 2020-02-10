import 'package:flutter/material.dart';

class FullPageError extends StatelessWidget {
  final String message;

  FullPageError({
    this.message = '',
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
            padding: const EdgeInsets.only(top: 50.0),
            child: Text('An error occurred :('),
          ),
        ],
      ),
    );
  }
}
