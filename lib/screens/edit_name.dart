import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/name_field.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class EditName extends StatefulWidget {
  @override
  _EditNameState createState() => _EditNameState();
}

class _EditNameState extends State<EditName> {
  bool isLoading = false;
  bool isCompleted = false;
  String newName = '';

  final nameFieldKey = GlobalKey<NameFieldState>();

  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Edit name',
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
      body: Builder(
        builder: (context) {
          if (isCompleted) {
            return completionScreen();
          }

          if (isLoading){
            return LoadingComponent(
              padding: EdgeInsets.all(30.0),
              title: 'Updating your name...',
            );
          }

          return ListView(
            padding: EdgeInsets.all(30.0),
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Text(
                      'Change your displayed name.',
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: NameField(key: nameFieldKey, autofocus: true,),
                  ),

                  buttons(),
                ],
              ),
            ],
          );
        },
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
                  color: ThemeColor.success,
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    updateName();
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
            padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
            child: Text(
              '$newName, your new name has been successfully updated.',
              style: TextStyle(fontSize: 25.0),
            ),
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
                    Text('Thanks!', style: TextStyle(color: Colors.white, fontSize: 20.0),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future updateName() async {
    setState(() {
      isLoading = true;
    });

    newName = nameFieldKey.currentState.fieldValue;

    try {
      final respName = await Mutations.updateName(context, newName);

      var userDataModel = Provider.of<UserDataModel>(context);
      userDataModel.setName(respName);

      setState(() {
        isCompleted = true;
        isLoading = false;
      });

    } catch (err) {
      setState(() {
        isLoading = false;
      });

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.error,
        message: err.toString(),
      )..show(context);
    }
  }
}
