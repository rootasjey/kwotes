import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/email_field.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class EditEmail extends StatefulWidget {
  @override
  _EditEmailState createState() => _EditEmailState();
}

class _EditEmailState extends State<EditEmail> {
  bool _isLoading = false;
  bool _isCompleted = false;
  String newEmail = '';

  final _emailFieldKey = GlobalKey<EmailFieldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Email'),),
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
                          padding: EdgeInsets.only(top: 25.0),
                          child: Text(
                            'You will receive a message to your new email address inbox.',
                            style: TextStyle(fontSize: 25.0),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 25.0),
                          child: Text(
                            'Click on the link inside this email to validate the change.',
                            style: TextStyle(fontSize: 17.0),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: EmailField(key: _emailFieldKey,),
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
                                        final booleanMessage = await updateEmail();

                                        final success = booleanMessage.boolean ? true : false;
                                        setState(() { _isLoading = false; });

                                        if (!success) {
                                          Scaffold.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                backgroundColor: ThemeColor.secondary,
                                                content: Text(
                                                  '${booleanMessage.message}',
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
                      title: 'Sending you a message to your new email address...',
                    ),

                ],
              )
            ],
          );
        },
      ),
    );
  }

  Future<BooleanMessage> updateEmail() {
    final String updateEmail = """
      query UpdateEmail(\$newEmail: String!) {
        updateEmailStepOne(newEmail: \$newEmail)
      }
    """;

    final httpClientModel = Provider.of<HttpClientsModel>(context);

    newEmail = _emailFieldKey.currentState.fieldValue;

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        document: updateEmail,
        variables: {'newEmail': newEmail},
      )
    )
    .then((queryResult) {
      if (queryResult.hasErrors) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.errors.first.message
        );
      }

      return BooleanMessage(boolean: true);
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
            padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
            child: Text(
              'We\'ve sent you an email to your new address. Go to your inbox and click on the link to validate it.',
              style: TextStyle(fontSize: 25.0),
            ),
          ),

          Text(
            'Do not forget to check your spam folder if you do not see the email.',
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
                    Text('Will check', style: TextStyle(color: Colors.white, fontSize: 20.0),),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: FlatButton(
              onPressed: () {
                setState(() { _isCompleted = false; });
              },
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text('Try another email', style: TextStyle(fontSize: 20.0),),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
