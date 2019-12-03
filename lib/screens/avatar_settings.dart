import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/error_reason.dart';
import 'package:memorare/types/try_response.dart';
import 'package:provider/provider.dart';

class AvatarSettingsComponent extends StatefulWidget {
  @override
  _AvatarSettingsComponentState createState() => _AvatarSettingsComponentState();
}

class _AvatarSettingsComponentState extends State<AvatarSettingsComponent> {
  String newImgUrl = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataModel>(context);

    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: IconButton(
        icon: Stack(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: userData.data.imgUrl.length > 0 ?
                NetworkImage('${userData.data.imgUrl}') :
                AssetImage('assets/images/monk.png'),
              maxRadius: 50.0,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(
                Icons.settings,
                color: Color(0xFF34495E),
                size: 30.0,
              ),
            )
          ],
        ),
        onPressed: () async {
          var success = await showAvatarDialog();
          if (success == null) { return; }

          Scaffold.of(context)
            .showSnackBar(
              SnackBar(
                backgroundColor: success ? ThemeColor.success : ThemeColor.error,
                content: Text(
                  success ?
                  'Your image has been successfully updated.' :
                  'There was an error while updating your image. Try again later.',
                  style: TextStyle(color: Colors.white),
                ),
              )
            );
        },
        iconSize: 100.0,
      ),
    );
  }

  Future<bool> showAvatarDialog() {
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: 'Update avatar',
      context: context,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (
        BuildContext context,
        Animation animation,
        Animation secondaryAnimation) {
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
                              fontSize: 35,
                              // fontWeight: FontWeight.bold,
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
                                      color: Color(0xFF02ECC7),
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
                                        var tryResponse = await updateAvatar();
                                        setState(() { isLoading = false; });

                                        var success = tryResponse.hasErrors ? false : true;
                                        Navigator.of(context).pop(success);
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

                  if (isLoading)
                    LoadingComponent(title: 'Saving...',),
                ],
              ),
            ],
          ),
        );
      }
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
}
