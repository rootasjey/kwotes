import 'package:flutter/material.dart';
import 'package:memorare/screens/delete_account.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/screens/edit_avatar.dart';
import 'package:memorare/screens/edit_email.dart';
import 'package:memorare/screens/edit_password.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
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
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: IconButton(
                        icon: Stack(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: userData.data.imgUrl.length > 0 ?
                                NetworkImage('${userData.data.imgUrl}') :
                                AssetImage('assets/images/monk.png'),
                              maxRadius: 50.0,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(
                                Icons.settings,
                                color: Color(0xFF34495E),
                                size: 30.0,
                              ),
                            )
                          ],
                        ),
                        onPressed: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return EditAvatar();
                              }
                            )
                          );
                        },
                        iconSize: 100.0,
                      ),
                    ),

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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return EditEmail();
                        }
                      )
                    );
                  },
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return EditPassword();
                        }
                      )
                    );
                  },
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
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return DeleteAccount();
                          }
                        )
                      );
                    },
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
