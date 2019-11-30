
import 'package:flutter/material.dart';
import 'package:memorare/login.dart';
import 'package:memorare/models/httpClients.dart';
import 'package:provider/provider.dart';

import 'models/userData.dart';

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
                    Provider.of<UserDataModel>(context).data?.name ??
                    'Hi Anonymous!',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                if (Provider.of<UserDataModel>(context).isAuthenticated)
                  ...authWidgets(context),
                if (!Provider.of<UserDataModel>(context).isAuthenticated)
                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return Login();
                            }
                          )
                        );
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

  List<Widget> authWidgets(BuildContext context) {
    return [
      Padding(
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: RaisedButton(
          color: Color(0xFFF56498),
          onPressed: () {
            Provider.of<UserDataModel>(context)
              ..clear()
              ..setAuthenticated(false);

            Provider.of<HttpClientsModel>(context).clearToken();
          },
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Sign Out',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ),
        ),
      ),
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {},
      ),
      Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            Divider(),
            FlatButton(
              child: ListTile(
                leading: Icon(Icons.list, size: 30.0,),
                title: Text('Published quotes', style: TextStyle(fontSize: 20.0),),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    ];
  }
}
