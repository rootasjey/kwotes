import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/error_reason.dart';
import 'package:memorare/types/try_response.dart';
import 'package:provider/provider.dart';

class EditAvatar extends StatefulWidget {
  @override
  _EditAvatarState createState() => _EditAvatarState();
}

class _EditAvatarState extends State<EditAvatar> {
  String newImgUrl = '';
  bool _isLoading = false;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update avatar'),),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Enter the URL of your new avatar.',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: CircleAvatar(
                        backgroundImage: newImgUrl.isEmpty ?
                          AssetImage('assets/images/monk.png') :
                          NetworkImage(newImgUrl),
                        maxRadius: 50.0,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.link),
                          labelText: 'URL'
                        ),
                        onChanged: (value) {
                          newImgUrl = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'The new URL cannot be empty';
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
                                    var tryResponse = await updateAvatar();
                                    setState(() { _isLoading = false; });

                                    var success = tryResponse.hasErrors ? false : true;

                                    if (!success) {
                                      Scaffold.of(context)
                                        .showSnackBar(
                                          SnackBar(
                                            backgroundColor: ThemeColor.error,
                                            content: Text(
                                              'There was an error while updating your image. Try again later.',
                                              style: TextStyle(color: Colors.white),
                                            ),
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
                    )
                  ],
                ),
              ),

              if (_isLoading)
                LoadingComponent(title: 'Saving...',),

              if (_isCompleted)
                completionScreen(),
            ],
          ),
        ],
      ),
    );
  }

  Future<TryResponse> updateAvatar() {
    final String updateImgURL = """
      mutation UpdateImgUrl(\$imgUrl: String!) {
        updateImgUrl(imgUrl: \$imgUrl) {
          imgUrl
        }
      }
    """;

    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(MutationOptions(
      document: updateImgURL,
      variables: {'imgUrl': newImgUrl},
    ))
    .then((queryResult) {
      if (queryResult.hasErrors) {
        return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
      }

      Map<String, dynamic> jsonMap = queryResult.data['updateImgUrl'];

      final String imgUrl = jsonMap['imgUrl'];

      var userDataModel = Provider.of<UserDataModel>(context);

      userDataModel.setImgUrl(imgUrl);

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
        crossAxisAlignment: CrossAxisAlignment.center,
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
              'Your avatar has been successfully updated.',
              style: TextStyle(fontSize: 25.0,),
              textAlign: TextAlign.center,
            ),
          ),

          Text(
            'Everything is new and shine.',
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
                    Text('Alright', style: TextStyle(color: Colors.white, fontSize: 20.0),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
