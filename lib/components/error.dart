import 'package:flutter/material.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/credentials.dart';
import 'package:memorare/types/error_reason.dart';
import 'package:memorare/types/try_response.dart';
import 'package:memorare/types/user_data.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: Delete this component
class ErrorComponent extends StatelessWidget {
  final String description;
  final String title;
  final Function onRefresh;

  ErrorComponent({this.description, this.onRefresh, this.title});

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

    final httpClientModel = Provider.of<HttpClientsModel>(context, listen: false);

    return httpClientModel.client.value.mutate(MutationOptions(
        documentNode: parseString(signinMutation),
        variables: {'email': credentials.email, 'password': credentials.password},
      ))
      .then((queryResult) {
        if (queryResult.hasException) {
          return TryResponse(hasErrors: true, reason: ErrorReason.server);
        }

        Map<String, dynamic> signinJson  = queryResult.data['signin'];

        var userData = UserData.fromJSON(signinJson);

        final userDataModel = Provider.of<UserDataModel>(context, listen: false);

        userDataModel
          ..update(userData)
          ..setAuthenticated(true)
          ..saveToFile(signinJson);

        Provider.of<HttpClientsModel>(context).setToken(token: userData.token);

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
      body: Container(
        padding: EdgeInsets.all(10.0),
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
                description,
                style: TextStyle(
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: RaisedButton(
                color: ThemeColor.error,
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
                onPressed: () async {
                  final url = 'mailto:mobile_issues@memorare.app?subject=Mobile%20Issues&body=Issue%20description:%20$description';

                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
              ),
            ),

            if (onRefresh != null)
              Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: FlatButton(
                  onPressed: () {
                    onRefresh();
                  },
                  child: Text(
                    'Refresh'
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
