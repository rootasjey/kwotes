import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/credentials.dart';
import 'package:memorare/types/error_reason.dart';
import 'package:memorare/types/try_response.dart';
import 'package:memorare/types/user_data.dart';
import 'package:provider/provider.dart';

class ErrorComponent extends StatelessWidget {
  final String description;
  final String title;

  ErrorComponent({this.description, this.title});

  static Future<TryResponse> trySignin(BuildContext context) async {
    final String signinMutation = """
      mutation Signin(\$email: String!, \$password: String!) {
        signin(email: \$email, password: \$password) {
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

    final credentials = await Credentials.readFromFile();

    if (credentials == null ||
      credentials.email.isEmpty ||
      credentials.password.isEmpty) {
      return TryResponse(hasErrors: true, reason: ErrorReason.credentials);
    }

    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.client.value.mutate(MutationOptions(
        document: signinMutation,
        variables: {'email': credentials.email, 'password': credentials.password},
      ))
      .then((queryResult) {
        if (queryResult.hasErrors) {
          return TryResponse(hasErrors: true, reason: ErrorReason.server);
        }

        Map<String, dynamic> signinJson  = queryResult.data['signin'];

        var userData = UserData.fromJSON(signinJson);

        var userDataModel = Provider.of<UserDataModel>(context);

        userDataModel
          ..update(userData)
          ..setAuthenticated(true)
          ..saveToFile(signinJson);

        Provider.of<HttpClientsModel>(context).setToken(userData.token);
        return TryResponse(hasErrors: false, reason: ErrorReason.none);
      })
      .catchError((onError) {
        print(onError);
        return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
      });
  }

  static bool isJWTRelated(String str) {
    return str.toLowerCase().contains('jwt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Something unexpected happenned.',
              style: TextStyle(
                fontSize: 40.0,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'Details: $description',
                style: TextStyle(
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ReportButtonComponent(),
          ],
        ),
      ),
    );
  }
}

// Because cannot use Scaffold.of(context).showSnackBar
// on the ErrorComponent.
class ReportButtonComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: RaisedButton(
        color: ThemeColor.secondary,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Report',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25.0,
            ),
          ),
        ),
        onPressed: () {
          Scaffold.of(context)
            .showSnackBar(
              SnackBar(
                content: Text('Thank you for helping.'),
              )
            );

          Navigator.of(context).pop();
        },
      ),
    );
  }
}
