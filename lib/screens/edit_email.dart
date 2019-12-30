import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:gql/language.dart';
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
  bool isLoading = false;
  bool isCompleted = false;
  String newEmail = '';

  final emailFieldKey = GlobalKey<EmailFieldState>();

  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Edit email',
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
              title: 'Sending you a message to your new email address...',
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
                      'You will receive a message to your new email address inbox.',
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),

                  Opacity(
                    opacity: 0.6,
                    child: Padding(
                      padding: EdgeInsets.only(top: 25.0),
                      child: Text(
                        'Click on the link inside this email to validate the change.',
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: EmailField(key: emailFieldKey,),
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
                    setState(() { isLoading = true; });
                    final booleanMessage = await updateEmail();

                    final success = booleanMessage.boolean ? true : false;
                    setState(() { isLoading = false; });

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
                setState(() { isCompleted = false; });
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


  Future<BooleanMessage> updateEmail() {
    final String updateEmail = """
      query UpdateEmail(\$newEmail: String!) {
        updateEmailStepOne(newEmail: \$newEmail)
      }
    """;

    final httpClientModel = Provider.of<HttpClientsModel>(context);

    newEmail = emailFieldKey.currentState.fieldValue;

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: parseString(updateEmail),
        variables: {'newEmail': newEmail},
      )
    )
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }
}
