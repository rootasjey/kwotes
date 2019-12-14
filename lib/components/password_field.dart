import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class PasswordField extends StatefulWidget {
  final String label;

  @override
  PasswordFieldState createState() => PasswordFieldState();

  PasswordField({ Key key, this.label = 'Password' }): super(key: key);
}

class PasswordFieldState extends State<PasswordField> {
  // Private props.
  final _passwordFieldKey = GlobalKey<FormFieldState>();

  bool _serverValidator = true;
  String _serverValidatorMessage = '';
  String _password = '';

  bool isChecking = false;

  final _duration = Duration(milliseconds: 500);
  Timer _timer;

  final String _defaultErrorMessage = """
    The password must contain a minimum of 8 characters,
    at least 1 number, 1 lower-case letter, 1 upper-case letter.
  """;

  // Public props.
  /// Field's value.
  String get fieldValue => _password;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TextFormField(
          key: _passwordFieldKey,
          decoration: InputDecoration(
            icon: Icon(Icons.lock_outline),
            labelText: widget.label,
            errorMaxLines: 2,
          ),
          obscureText: true,
          onChanged: (value) async {
            _password = value;

            _timer?.cancel();

            _timer = Timer(
              _duration,
              () async {
                setState(() {
                  isChecking = true;
                });

                var booleanMessage = await isPasswordValid(value);

                setState(() {
                  isChecking = false;
                });

                if (booleanMessage.boolean) {
                  _serverValidator = true;
                  _serverValidatorMessage = booleanMessage.message;
                  _passwordFieldKey.currentState.validate();
                  return;
                }

                _serverValidator = false;
                _serverValidatorMessage = booleanMessage.message;

                _passwordFieldKey.currentState.validate();
              }
            );
          },
          validator: (value) {
            if (_password.isEmpty) {
              return 'Password cannot be empty';
            }

            if (_password.length < 8) {
              return 'Password must contain at least 3 characters';
            }

            if (!_serverValidator) {
              Scaffold.of(context)
                .showSnackBar(
                  SnackBar(
                    backgroundColor: ThemeColor.error,
                    content: Text(_serverValidatorMessage),
                  )
                );

              return _serverValidatorMessage.isNotEmpty ?
                _serverValidatorMessage :
                _defaultErrorMessage;
            }

            return null;
          },
        ),
        if (isChecking)
          Positioned(
            width: 15.0,
            height: 15.0,
            right: 0,
            bottom: _passwordFieldKey.currentState.errorText == null ? 15 : 45,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Future<BooleanMessage> isPasswordValid(String passwordValue) {
    if (passwordValue == null || passwordValue.isEmpty) {
      return Future.value(
        BooleanMessage(
          boolean: false,
          message: 'Password cannot be null or empty.'
        )
      );
    }

    if (passwordValue.length < 8) {
      return Future.value(
        BooleanMessage(
          boolean: false,
          message: 'Password must contain at least 8 characters.'
        )
      );
    }

    final String isPasswordValid = """
      query IsPasswordValid(\$password: String!) {
        isPasswordValid(password: \$password) {
          bool
          message
        }
      }
    """;

    var client = Provider.of<HttpClientsModel>(context).defaultClient;

    return client.value.mutate(
      MutationOptions(
        documentNode: parseString(isPasswordValid),
        variables: {'password': passwordValue},
      ))
      .then((queryResult) {
        if (queryResult.hasException) {
          return BooleanMessage(
            boolean: false,
            message: queryResult.exception.graphqlErrors.first.toString(),
          );
        }

        Map<String, dynamic> json = queryResult.data['isPasswordValid'];
        var booleanMessage = BooleanMessage.fromJSON(json);

        return booleanMessage;
      })
      .catchError((onError) {
        return BooleanMessage(
          boolean: false,
          message: 'There was an issue while communicating with the server.'
        );
      }
    );
  }
}
