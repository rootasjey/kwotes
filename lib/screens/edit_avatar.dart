import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class EditAvatar extends StatefulWidget {
  @override
  _EditAvatarState createState() => _EditAvatarState();
}

class _EditAvatarState extends State<EditAvatar> {
  String newImgUrl = '';
  bool isLoading = false;
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    if (isLoading) {
      return LoadingComponent(title: 'Saving...',);
    }

    if (isCompleted) {
      return completionScreen();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Update avatar',
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
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Enter the URL of your new avatar.',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: newImgUrl.isEmpty ?
                  CircleAvatar(
                    radius: 70.0,
                    child: Icon(Icons.person_outline, size: 40.0,),
                  ):
                  CircleAvatar(
                    backgroundImage: NetworkImage(newImgUrl),
                    radius: 70.0,
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

              buttons(),
            ],
          ),
        ],
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
                    updateAvatar();
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

  Future updateAvatar() async {
    setState(() {
      isLoading = true;
    });

    final tryResponse = await Mutations.updateImgUrl(context, newImgUrl);

    setState(() {
      isLoading = false;
    });

    final success = tryResponse.hasErrors ? false : true;

    if (!success) {
      Flushbar(
        backgroundColor: ThemeColor.error,
        message: 'There was an error while updating your image. Try again later.',
      )..show(context);

      return;
    }

    setState(() {
      isCompleted = true;
    });
  }
}
