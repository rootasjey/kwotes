import 'package:flutter/material.dart';

class EmptyFlatCard extends StatelessWidget {
  final Function onPressed;

  EmptyFlatCard({
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 600.0,
          height: 200.0,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'There is no temporary quotes at the moment.',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        FlatButton(
          onPressed: onPressed,
          child: Opacity(
            opacity: .6,
            child: Text('Refresh')
          ),
        )
      ],
    );
  }
}
