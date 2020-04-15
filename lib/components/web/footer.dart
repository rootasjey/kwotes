import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/snack.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatefulWidget {
  final ScrollController pageScrollController;

  Footer({this.pageScrollController});

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
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.1),
      ),
      child: Wrap(
        runSpacing: 80.0,
        alignment: WrapAlignment.spaceAround,
        children: <Widget>[
          languages(),

          developers(),

          resourcesLinks(),
        ],
      ),
    );
  }

  Widget developers() {
    return Column(
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
            await launch('https://github.com/outofcontextapp/app');
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
    );
  }

  Widget languages() {
    return Column(
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
            updateUserAccountLang();
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
            updateUserAccountLang();
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
    );
  }

  Widget resourcesLinks() {
    return Column(
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
    );
  }

  void notifyLangSuccess() {
    if (widget.pageScrollController != null) {
      widget.pageScrollController.animateTo(
        0.0,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }

    showSnack(
      context: context,
      message: 'Your language has been successfully updated.',
      type: SnackType.success,
    );
  }

  void updateUserAccountLang() async {
    final userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth == null) {
      notifyLangSuccess();
      return;
    }

    try {
     await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .updateData({
          'lang': userState.lang,
        }
      );

      notifyLangSuccess();

    } catch (error) {
      debugPrint(error.toString());

      showSnack(
        context: context,
        message: 'Sorry, there was an error while updating your language.',
        type: SnackType.error,
      );
    }
  }
}
