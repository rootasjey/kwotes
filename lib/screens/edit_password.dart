import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/password_field.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class EditPassword extends StatefulWidget {
  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  String oldPassword = '';
  String confirmPassword = '';

  bool isLoading = false;
  bool isCompleted = false;

  final newPasswordKey = GlobalKey<PasswordFieldState>();
  final confirmPasswordFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Edit password',
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

          if (isLoading) {
            return LoadingComponent(
              padding: EdgeInsets.all(30.0),
              title: 'Saving your new passowrd...',
            );
          }

          return ListView(
            padding: EdgeInsets.all(30.0),
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Enter your current password and choose a new one.',
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: 'Old password'
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        oldPassword = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'The new URL cannot be empty';
                        }

                        return null;
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: PasswordField(key: newPasswordKey, label: 'New password',),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          key: confirmPasswordFieldKey,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock_outline),
                            labelText: 'Confirm Password',
                            errorMaxLines: 2
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            confirmPassword = value;
                            confirmPasswordFieldKey.currentState.validate();
                          },
                          validator: (value) {
                            if (confirmPassword.isEmpty) {
                              return 'Password confirmation cannot be empty';
                            }

                            if (confirmPassword != newPasswordKey.currentState.fieldValue) {
                              return 'Password and confirm password must match.';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  buttons(),
                ],
              ),
            ],
          );
        },
      )
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
                    updatePassword();
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
              'Your password has been successfully updated!',
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
                    Text('Alright', style: TextStyle(color: Colors.white, fontSize: 20.0),),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future updatePassword() async {
    setState(() { isLoading = true; });

    final booleanMessage = await Mutations
      .updatePassword(context, oldPassword, confirmPassword);

    setState(() {
      isLoading = false;
    });

    final success = booleanMessage.boolean;

    if (!success) {
      Flushbar(
        backgroundColor: ThemeColor.error,
        message: booleanMessage.message,
      )..show(context);

      return;
    }

    setState(() {
      isCompleted = true;
    });
  }
}
