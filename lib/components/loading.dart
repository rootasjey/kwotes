import 'package:flutter/material.dart';

class LoadingComponent extends StatelessWidget {
  final String title;

  LoadingComponent({this.title = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('Loading...'),
      ],
    );
  }
}
