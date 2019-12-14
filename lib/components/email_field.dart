import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:provider/provider.dart';

class EmailField extends StatefulWidget {
  @override
  EmailFieldState createState() => EmailFieldState();

  EmailField({ Key key }): super(key: key);
}

class EmailFieldState extends State<EmailField> {
  // Private props.
  final _emailFieldKey = GlobalKey<FormFieldState>();

  bool _serverValidator = true;
  String _serverValidatorMessage = '';
  String _email = '';

  final _duration = Duration(milliseconds: 500);
  Timer _timer;

  /// True if the input's value is being checked at the backend.
  bool isChecking = false;

  final String _defaultErrorMessage = 'Please enter a valid email.';

  // Public props.
  /// Field's value.
  String get fieldValue => _email;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        TextFormField(
          key: _emailFieldKey,
          decoration: InputDecoration(
            icon: Icon(Icons.email),
            labelText: 'Email',
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) async {
            _email = value;

            _timer?.cancel();

            _timer = Timer(
              _duration,
              () async {
                setState(() {
                  isChecking = true;
                });

                var booleanMessage = await isEmailValid(value);
                setState(() {
                  isChecking = false;
                });

                if (booleanMessage.boolean) {
                  _serverValidator = true;
                  _serverValidatorMessage = booleanMessage.message;
                  _emailFieldKey.currentState.validate();
                  return;
                }

                _serverValidator = false;
                _serverValidatorMessage = booleanMessage.message;

                _emailFieldKey.currentState.validate();
              }
            );
          },
          validator: (value) {
            if (_email.isEmpty) {
              return 'Email cannot be empty';
            }

            if (!_serverValidator) {
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
            bottom: _emailFieldKey.currentState.errorText == null ? 15 : 35,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Future<BooleanMessage> isEmailValid(String emailValue) {
    if (emailValue == null || emailValue.isEmpty) {
      return Future.value(
        BooleanMessage(
          boolean: false,
          message: 'Email cannot be null or empty.'
        )
      );
    }

    final String isEmailValid = """
      query IsEmailValid(\$email: String!) {
        isEmailValid(email: \$email) {
          bool
          message
        }
      }
    """;

    var client = Provider.of<HttpClientsModel>(context).defaultClient;

    return client.value.mutate(
      MutationOptions(
        documentNode: parseString(isEmailValid),
        variables: {'email': emailValue},
      ))
      .then((queryResult) {
        if (queryResult.hasException) {
          return BooleanMessage(
            boolean: false,
            message: queryResult.exception.graphqlErrors.first.toString(),
          );
        }

        Map<String, dynamic> json = queryResult.data['isEmailValid'];
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
