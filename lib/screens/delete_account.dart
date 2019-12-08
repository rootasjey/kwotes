import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/error_reason.dart';
import 'package:memorare/types/try_response.dart';
import 'package:provider/provider.dart';

class DeleteAccount extends StatefulWidget {
  @override
  DeleteAccountState createState() => DeleteAccountState();
}

class DeleteAccountState extends State<DeleteAccount> {
  String password = '';
  bool _isLoading = false;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Account'),),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 25.0),
                      child: Text('Are you sure?',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: ListTile(
                        leading: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        title: Text(
                          'You will not be able to connect anymore',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      )
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: ListTile(
                        leading: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          'All your pubished quotes will not be deleted but will be disassociated with your account',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      )
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: ListTile(
                        leading: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text('All other data will be erased',
                        style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      )
                    ),

                    Container(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Text(
                        'Enter your password to confirm this action.',
                        style: TextStyle(color: ThemeColor.primary),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock),
                          labelText: 'Password'
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          password = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Your password cannot be empty.';
                          }

                          return null;
                        },
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
                                  color: ThemeColor.secondary,
                                  child: Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() { _isLoading = true; });
                                    var tryResponse = await deleteAccount();
                                    setState(() { _isLoading = false; });

                                    var success = tryResponse.hasErrors ? false : true;

                                    if (!success) {
                                      Scaffold.of(context)
                                        .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'There was a problem while deleting your account. Please try again later.',
                                              style: TextStyle(color: Colors.white),
                                            )
                                          )
                                        );

                                      return;
                                    }

                                    Provider.of<UserDataModel>(context).clear();
                                    Provider.of<HttpClientsModel>(context).clearToken();

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
                  title: 'Deleting your data...',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<TryResponse> deleteAccount() {
    final String deleteAccount = """
      mutation DeleteAccount(\$password: String!) {
        deleteAccount(password: \$password) {
          id
        }
      }
    """;

    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(MutationOptions(
      document: deleteAccount,
      variables: {'password': password},
    ))
    .then((queryResult) {
      if (queryResult.hasErrors) {
        return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
      }

      return TryResponse(hasErrors: false, reason: ErrorReason.none);
    })
    .catchError((error) {
      return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
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
              'Your account has been successfully deleted!',
              style: TextStyle(fontSize: 25.0),
            ),
          ),
          Text(
            'Hope we will see you again 🖐️ ',
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
                    Text('Cya', style: TextStyle(color: Colors.white, fontSize: 20.0),),
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
