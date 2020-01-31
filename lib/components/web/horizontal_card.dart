import 'package:flutter/material.dart';

class HorizontalCard extends StatefulWidget {
  final String name;
  final String authorName;
  final String referenceName;

  HorizontalCard({
    this.authorName = '',
    this.name,
    this.referenceName = '',
  });

  @override
  _HorizontalCardState createState() => _HorizontalCardState();
}

class _HorizontalCardState extends State<HorizontalCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700.0,
      height: 300.0,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 27.0,
                  ),
                ),
              ),
              Text(
                widget.authorName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
