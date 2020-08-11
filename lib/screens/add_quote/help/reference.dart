import 'package:flutter/material.dart';

class HelpReference extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 500.0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Text(
                'Help',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
          ),

          SizedBox(
            width: 500.0,
            child: Opacity(
              opacity: .6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '• Reference information are optional',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '• If you select the reference\'s name in the dropdown list, other fields can stay empty',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
