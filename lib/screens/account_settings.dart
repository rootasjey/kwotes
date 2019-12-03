import 'package:flutter/material.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/screens/avatar_settings.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AvatarSettingsComponent(),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: FlatButton(
                        child: Text(
                          userData.data.name,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        onPressed: () {},
                      )
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 20.0),),
                  ],
                ),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 20.0),),
                FlatButton(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.mail),
                        ),
                        Flexible(
                          child: Text(userData.data.email,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 20.0)
                          ),
                        )
                      ],
                    ),
                  ),
                  onPressed: () {},
                ),
                FlatButton(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.lock_open),
                        ),
                        Text('Password', style: TextStyle(fontSize: 20.0)),
                      ],
                    ),
                  ),
                  onPressed: () {},
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: FlatButton(
                    color: ThemeColor.secondary,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(Icons.lock_open, color: Colors.white,),
                          ),
                          Text('Delete account',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white
                            )
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
