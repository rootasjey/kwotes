import 'package:flutter/material.dart';

class LoadingComponent extends StatelessWidget {
  final Color backgroundColor;
  final Color color;
  final EdgeInsets padding;
  final String title;

  LoadingComponent({
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 0.8),
    this.color = Colors.white,
    this.title = 'Loading...',
    this.padding
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 100,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
