import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String description;
  final String title;

  EmptyView({this.description, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 35.0,
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
