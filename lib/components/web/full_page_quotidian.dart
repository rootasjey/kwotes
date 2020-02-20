import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

Quotidian _quotidian;

class FullPageQuotidian extends StatefulWidget {
  @override
  _FullPageQuotidianState createState() => _FullPageQuotidianState();
}

class _FullPageQuotidianState extends State<FullPageQuotidian> {
  bool isLoading = false;
  FirebaseUser userAuth;

  @override
  void initState() {
    super.initState();

    if (_quotidian != null) { return; }
    fetchQuotidian();
    checkAuthStatus();
  }

  void checkAuthStatus() async {
    userAuth = await FirebaseAuth.instance.currentUser();

    setState(() {});

    if (userAuth != null) {
      Language.fetchLang(userAuth);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: <Widget>[
          CircularProgressIndicator(),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 40.0,
            ),
          )
        ],
      );
    }

    if (!isLoading && _quotidian == null) {
      return Column(
        children: <Widget>[
          Text(
            'Sorry, an unexpected error happended :(',
            style: TextStyle(
              fontSize: 35.0,
            ),
          )
        ],
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height - 50.0,
          child: Padding(
            padding: EdgeInsets.all(70.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_quotidian.quote.name,
                  style: TextStyle(
                    fontSize: FontSize.hero(_quotidian.quote.name),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: SizedBox(
                    width: 200.0,
                    child: Divider(
                      color: Color(0xFF64C7FF),
                      thickness: 2.0,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Opacity(
                    opacity: .8,
                    child: FlatButton(
                      onPressed: () {
                        final id = _quotidian.quote.author.id;

                        FluroRouter.router.navigateTo(
                          context,
                          AuthorRoute.replaceFirst(':id', id)
                        );
                      },
                      child: Text(
                        _quotidian.quote.author.name,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    )
                  )
                ),

                if (_quotidian.quote.mainReference?.name != null &&
                  _quotidian.quote.mainReference.name.length > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Opacity(
                      opacity: .6,
                      child: FlatButton(
                        onPressed: () {
                          final id = _quotidian.quote.mainReference.id;

                          FluroRouter.router.navigateTo(
                            context,
                            ReferenceRoute.replaceFirst(':id', id)
                          );
                        },
                        child: Text(
                          _quotidian.quote.mainReference.name,
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      )
                    ),
                  ),
              ],
            ),
          ),
        ),

        userSection(),
      ],
    );
  }

  Widget userSection() {
    if (userAuth == null) {
      return signinButton();
    }

    return userActions();
  }

  Widget signinButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              FluroRouter.router.navigateTo(
                context,
                SigninRoute,
              );
            },
            child: Text(
              'Signin',
            ),
          )
        ],
      ),
    );
  }

  Widget userActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: () { print('fav'); },
            icon: Icon(Icons.favorite_border),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: IconButton(
              onPressed: () { print('share'); },
              icon: Icon(Icons.share),
            ),
          ),

          IconButton(
            onPressed: () { print('add list'); },
            icon: Icon(Icons.playlist_add),
          ),
        ],
      ),
    );
  }

  void fetchQuotidian() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await FirestoreApp.instance
        .collection('quotidians').doc('01:02:2020').get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      setState(() {
        _quotidian = Quotidian.fromJSON(doc.data());
        isLoading = false;
      });

    } catch (error, stackTrace) {
      debugPrint('error => $error');
      debugPrint(stackTrace.toString());

      setState(() {
        isLoading = false;
      });
    }
  }
}
