import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/email_field.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/name_field.dart';
import 'package:memorare/components/password_field.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/credentials.dart';
import 'package:memorare/types/user_data.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  @override
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _nameFieldKey = GlobalKey<NameFieldState>();
  final _emailFieldKey = GlobalKey<EmailFieldState>();
  final _passwordFieldKey = GlobalKey<PasswordFieldState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState>();

  bool _isLoading = false;
  bool _isCompleted = false;

  String confirmPassword = '';
  String email = '';
  String name = '';
  String password = '';

  final String signupMutation = """
    mutation Signup(\$email: String!, \$name: String!, \$password: String!) {
      signup(email: \$email, name: \$name password: \$password) {
        id
        imgUrl
        email
        lang
        name
        rights
        token
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Sign up to a new account.',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          NameField(key: _nameFieldKey),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          EmailField(key: _emailFieldKey),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          PasswordField(key: _passwordFieldKey),
                        ],
                      ),
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
                              confirmPassword = value;
                              _confirmPasswordFieldKey.currentState.validate();
                            },
                            validator: (value) {
                              if (confirmPassword.isEmpty) {
                                return 'Password confirmation cannot be empty';
                              }

                              if (confirmPassword != _passwordFieldKey.currentState.fieldValue) {
                                return 'Password and confirm password must match.';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    Mutation(
                      builder: (RunMutation runMutation, QueryResult result) {
                        return Padding(
                          padding: EdgeInsets.only(top: 60.0),
                          child: RaisedButton(
                            color: Color(0xFF2ECC71),
                            onPressed: () {
                              if (!_formKey.currentState.validate()) {
                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              name = _nameFieldKey.currentState.fieldValue;
                              email = _emailFieldKey.currentState.fieldValue;
                              password = _passwordFieldKey.currentState.fieldValue;

                              runMutation({
                                'email': email,
                                'name': name,
                                'password': password,
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Icon(Icons.arrow_forward, color: Colors.white,),
                                  )
                                ],
                              )
                            ),
                          ),
                        );
                      },
                      options: MutationOptions(
                        document: signupMutation,
                      ),
                      onCompleted: (dynamic resultData) {
                        if (resultData == null) { return; }

                        Map<String, dynamic> signupJson = resultData['signup'];

                        var userData = UserData.fromJSON(signupJson);
                        var userDataModel = Provider.of<UserDataModel>(context);

                        userDataModel
                          ..update(userData)
                          ..setAuthenticated(true)
                          ..saveToFile(signupJson);

                        Credentials(email: email, password: password).saveToFile();

                        Provider.of<HttpClientsModel>(context).setToken(userData.token);

                        setState(() {
                          _isLoading = false;
                          _isCompleted = true;
                        });
                      },
                      update: (Cache cache, QueryResult result) {
                        setState(() {
                          _isLoading = false;
                        });

                        if (result.hasErrors) {
                          for (var error in result.errors) {
                            Scaffold.of(context)
                              .showSnackBar(
                                SnackBar(
                                  backgroundColor: ThemeColor.error,
                                  content: Text(
                                    '${error.message}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                          }
                        }
                      },
                    ),
                  ],
                ),
              )
            ),

            if (_isCompleted)
              completionScreen(),

            if (_isLoading)
              LoadingComponent(title: 'Creating your account...'),
          ],
        ),
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
              'Your account has been successfully created!',
              style: TextStyle(fontSize: 25.0),
            ),
          ),
          Text(
            'Check your mail box and your spam folder to validate your account.',
            style: TextStyle(fontSize: 20.0),
          ),
          Padding(
            padding: EdgeInsets.only(top: 60),
            child: FlatButton(
              color: ThemeColor.success,
              onPressed: () { Navigator.of(context).pop(); },
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
