import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class DeleteAccount extends StatefulWidget {
  @override
  DeleteAccountState createState() => DeleteAccountState();
}

class DeleteAccountState extends State<DeleteAccount> {
  String password = '';

  bool isLoading = false;
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    if (isCompleted) {
      return completionScreen();
    }

    if (isLoading) {
      return LoadingComponent(
        padding: EdgeInsets.all(30.0),
        title: 'Deleting your data...',
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Delete account',
          style: TextStyle(
            color: accent,
            fontSize: 30.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: accent,),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Text('Are you sure?',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text(
                  '- You will not be able to connect anymore',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  '- All your pubished quotes will not be deleted but will be disassociated with your account',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  '- All other data will be erased',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    'Enter your password to confirm this action.',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                )
              ),

              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Password'
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Your password cannot be empty.';
                    }

                    return null;
                  },
                ),
              ),

              buttons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buttons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: FlatButton(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                  color: ThemeColor.error,
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    deleteAccount();
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget completionScreen() {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Icon(
              Icons.check_circle,
              color: ThemeColor.success,
              size: 90.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0, bottom: 20.0),
            child: Text(
              'Your account has been successfully deleted!',
              style: TextStyle(fontSize: 25.0),
            ),
          ),
          Text(
            'Hope we will see you again 🖐️ ',
            style: TextStyle(fontSize: 20.0),
          ),
          Padding(
            padding: EdgeInsets.only(top: 60),
            child: FlatButton(
              color: ThemeColor.success,
              onPressed: () { Navigator.of(context).pop(true); },
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(right: 10.0), child: Icon(Icons.check, color: Colors.white,),),
                    Text('Cya', style: TextStyle(color: Colors.white, fontSize: 20.0),),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future deleteAccount() async {
    setState(() {
      isLoading = true;
    });

    var tryResponse = await deleteAccount();

    setState(() {
      isLoading = false;
    });

    var success = tryResponse.hasErrors ? false : true;

    if (!success) {
      Flushbar(
        backgroundColor: ThemeColor.error,
        message: 'There was a problem while deleting your account. Please try again later.',
      )..show(context);

      return;
    }

    Provider.of<UserDataModel>(context).clear();
    Provider.of<HttpClientsModel>(context).clearToken();

    setState(() {
      isCompleted = true;
    });
  }
}
