import 'package:flutter/material.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/password_field.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class EditPassword extends StatefulWidget {
  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  String _oldPassword = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  bool _isCompleted = false;

  final _newPasswordKey = GlobalKey<PasswordFieldState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Password'),
      ),
      body: Builder(
        builder: (context) {
          return ListView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
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
                              _oldPassword = value;
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
                          child: PasswordField(key: _newPasswordKey, label: 'New password',),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextFormField(
                                key: _confirmPasswordFieldKey,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.lock_outline),
                                  labelText: 'Confirm Password',
                                  errorMaxLines: 2
                                ),
                                obscureText: true,
                                onChanged: (value) {
                                  _confirmPassword = value;
                                  _confirmPasswordFieldKey.currentState.validate();
                                },
                                validator: (value) {
                                  if (_confirmPassword.isEmpty) {
                                    return 'Password confirmation cannot be empty';
                                  }

                                  if (_confirmPassword != _newPasswordKey.currentState.fieldValue) {
                                    return 'Password and confirm password must match.';
                                  }

                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: RaisedButton(
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
                                        setState(() { _isLoading = true; });
                                        var booleanMessage = await updatePassword();
                                        setState(() { _isLoading = false; });

                                        var success = booleanMessage.boolean;

                                        if (!success) {
                                          Scaffold.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                backgroundColor: ThemeColor.error,
                                                content: Text(
                                                  booleanMessage.message,
                                                  style: TextStyle(color: Colors.white),
                                                )
                                              )
                                            );

                                          return;
                                        }

                                        setState(() {
                                          _isCompleted = true;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),

                      ],
                    ),
                  ),

                  if (_isCompleted)
                    completionScreen(),

                  if (_isLoading)
                    LoadingComponent(
                      padding: EdgeInsets.all(30.0),
                      title: 'Saving your new passowrd...',
                    ),
                ],
              )
            ],
          );
        },
      )
    );
  }

  Future<BooleanMessage> updatePassword() {
    final String updatePassword = """
      mutation UpdatePasword(\$oldPassword: String!, \$newPassword: String!) {
        updatePassword(oldPassword: \$oldPassword, newPassword: \$newPassword) {
          id
        }
      }
    """;

    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
      documentNode: parseString(updatePassword),
      variables: {
        'oldPassword': _oldPassword,
        'newPassword': _confirmPassword,
      },
    ))
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(boolean: false, message: queryResult.exception.graphqlErrors.first.message);
      }

      return BooleanMessage(boolean: true,);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
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

}
