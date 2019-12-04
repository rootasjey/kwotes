import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:provider/provider.dart';

class NameField extends StatefulWidget {
  @override
  NameFieldState createState() => NameFieldState();

  NameField({ Key key }): super(key: key);
}

class NameFieldState extends State<NameField> {
  // Private props.
  final _nameFieldKey = GlobalKey<FormFieldState>();

  bool _serverValidator = true;
  String _serverValidatorMessage = '';
  String _name = '';

  bool isChecking = false;

  final _duration = Duration(milliseconds: 500);
  Timer _timer;

  final String _defaultErrorMessage = """
    Please enter an alphanumerical name containing at least 3 characters.
    Name can only contain alphanumerical characters, dots, spaces, hyphens and underscores.
  """;

  // Public props.
  /// Field's value.
  String get fieldValue => _name;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TextFormField(
          key: _nameFieldKey,
          decoration: InputDecoration(
            icon: Icon(Icons.perm_identity),
            labelText: 'Name',
            errorMaxLines: 2,
          ),
          onChanged: (value) async {
            _name = value;

            _timer?.cancel();

            _timer = Timer(
              _duration,
              () async {
                setState(() {
                  isChecking = true;
                });

                var booleanMessage = await isNameValid(value);

                setState(() {
                  isChecking = false;
                });

                if (booleanMessage.boolean) {
                  _serverValidator = true;
                  _serverValidatorMessage = booleanMessage.message;
                  _nameFieldKey.currentState.validate();
                  return;
                }

                _serverValidator = false;
                _serverValidatorMessage = booleanMessage.message;

                _nameFieldKey.currentState.validate();
              }
            );
          },
          validator: (value) {
            if (_name.isEmpty) {
              return 'Name cannot be empty';
            }

            if (_name.length < 3) {
              return 'Name must contain at least 3 characters';
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
            bottom: _nameFieldKey.currentState.errorText == null ? 15 : 45,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Future<BooleanMessage> isNameValid(String nameValue) {
    if (nameValue == null || nameValue.isEmpty) {
      return Future.value(
        BooleanMessage(
          boolean: false,
          message: 'Name cannot be null or empty.'
        )
      );
    }

    if (nameValue.length < 3) {
      return Future.value(
        BooleanMessage(
          boolean: false,
          message: 'Name must contain at least 3 characters.'
        )
      );
    }

    final String isNameValid = """
      query IsNameValid(\$name: String!) {
        isNameValid(name: \$name) {
          bool
          message
        }
      }
    """;

    var client = Provider.of<HttpClientsModel>(context).defaultClient;

    return client.value.mutate(
      MutationOptions(
        document: isNameValid,
        variables: {'name': nameValue},
      ))
      .then((queryResult) {
        if (queryResult.hasErrors) {
          return BooleanMessage(
            boolean: false,
            message: queryResult.errors.first.toString(),
          );
        }

        Map<String, dynamic> json = queryResult.data['isNameValid'];
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
