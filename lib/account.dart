
import 'package:flutter/material.dart';

class AccountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/monk.png'),
                  maxRadius: 50.0,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Hi Anonymous!',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: RaisedButton(
                    onPressed: () {
                      print('navigate to sign in');
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Sign In',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 20.0, top: 80.0, right: 20.0),
          ),
        ],
      ),
    );
  }
}
