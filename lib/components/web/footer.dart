import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatefulWidget {
  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 60.0,
        vertical: 100.0,
      ),
      color: Color(0xFFE6E6E6),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 30.0,
                  left: 15.0
                ),
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'LANGUAGE',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),

              FlatButton(
                onPressed: () async {
                  Language.setLang(Language.en);
                  updateUserLang();
                },
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'English',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: () {
                  Language.setLang(Language.fr);
                  updateUserLang();
                },
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'Français',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 30.0,
                  left: 15.0
                ),
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'DEVELOPERS',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),

              FlatButton(
                onPressed: null,
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'Documentation',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: null,
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'API References',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: null,
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'API Status',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: () async {
                  await launch('https://github.com/memorare/app');
                },
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'GitHub',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 30.0,
                  left: 15.0
                ),
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'RESOURCES',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),

              FlatButton(
                onPressed: () {
                  FluroRouter.router.navigateTo(context, AboutRoute);
                },
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: () {
                  FluroRouter.router.navigateTo(context, ContactRoute);
                },
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'Contact',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: () {
                  FluroRouter.router.navigateTo(context, PrivacyRoute);
                },
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'Privacy & Terms',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future updateUserLang() async {
    final userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth == null) { return; }

    try {
     await FirestoreApp.instance
      .collection('users')
      .doc(userAuth.uid)
      .update(
        data: {
          'lang': Language.current,
        }
      );

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Your language has been successfully updated.'),
        )
      );
    } catch (error) {
      debugPrint(error.toString());

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Sorry, There was an error while updating your language.'),
        )
      );
    }
  }
}
