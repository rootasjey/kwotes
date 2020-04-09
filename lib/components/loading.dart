import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';

class LoadingComponent extends StatelessWidget {
  final EdgeInsets padding;
  final String title;

  LoadingComponent({
    this.title = 'Loading...',
    this.padding
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 100,
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(stateColors.primary),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
