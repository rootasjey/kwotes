
import 'package:flutter/material.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/screens/account_settings.dart';
import 'package:memorare/screens/app_settings.dart';
import 'package:memorare/screens/connect.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/screens/published_quotes.dart';
import 'package:memorare/screens/temp_quotes.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/credentials.dart';
import 'package:provider/provider.dart';

class Account extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataModel>(context);

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: userData.data.imgUrl.length > 0 ?
                    NetworkImage('${userData.data.imgUrl}') :
                    AssetImage('assets/images/monk.png'),
                  maxRadius: 50.0,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    userData.data.name.length > 0 ?
                     userData.data.name :
                    'Hi Anonymous!',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                if (userData.isAuthenticated)
                  ...authWidgets(context),
                if (!userData.isAuthenticated)
                  ...nonAuthWidgets(context),
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
          color: Provider.of<ThemeColor>(context).accent,
          onPressed: () {
            Provider.of<UserDataModel>(context)
              ..clear()
              ..setAuthenticated(false);

            Credentials.clearFile();

            Provider.of<HttpClientsModel>(context).clearToken();

            Scaffold.of(context)
              .showSnackBar(
                SnackBar(
                  backgroundColor: Color(0xFF2ECC71),
                  content: Text(
                    'You have been successfully disconnected.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              );
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
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AccountSettings();
              }
            )
          );
        },
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return MyPublishedQuotes();
                    }
                  )
                );
              },
            ),
            FlatButton(
              child: ListTile(
                leading: Icon(Icons.timelapse, size: 30.0,),
                title: Text('Temporary quotes', style: TextStyle(fontSize: 20.0),),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return MyTempQuotes();
                    }
                  )
                );
              },
            ),
            FlatButton(
              child: ListTile(
                leading: Icon(Icons.settings, size: 30.0,),
                title: Text('App settings', style: TextStyle(fontSize: 20.0),),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AppPageSettings();
                    }
                  )
                );
              },
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> nonAuthWidgets(BuildContext context) {
    return [
      Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: RaisedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return Connect();
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
      )
    ];
  }
}
