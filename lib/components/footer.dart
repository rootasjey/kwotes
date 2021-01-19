import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/types/enums.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/screens/about.dart';
import 'package:figstyle/screens/contact.dart';
import 'package:figstyle/screens/tos.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/language.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatefulWidget {
  final ScrollController pageScrollController;
  final bool closeModalOnNav;
  final bool autoNavToHome;

  Footer({
    this.autoNavToHome = true,
    this.pageScrollController,
    this.closeModalOnNav = false,
  });

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 60.0,
        vertical: 90.0,
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
          padding: const EdgeInsets.only(bottom: 30.0, left: 15.0),
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
            )),
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
            )),
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
            )),
        FlatButton(
            onPressed: () async {
              onBeforeNav();
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
            )),
      ],
    );
  }

  Widget languages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0, left: 15.0),
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
              onBeforeNav();
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
            )),
        FlatButton(
            onPressed: () {
              onBeforeNav();
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
            )),
      ],
    );
  }

  Widget resourcesLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0, left: 15.0),
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
              onBeforeNav();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => About()),
              );
            },
            child: Opacity(
              opacity: .5,
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            )),
        FlatButton(
            onPressed: () {
              onBeforeNav();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => Contact()),
              );
            },
            child: Opacity(
              opacity: .5,
              child: Text(
                'Contact',
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            )),
        FlatButton(
            onPressed: () {
              onBeforeNav();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => Tos()),
              );
            },
            child: Opacity(
              opacity: .5,
              child: Text(
                'Privacy & Terms',
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            )),
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
    } else if (widget.autoNavToHome) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => Home()),
      );
    }

    showSnack(
      context: context,
      message: 'Your language has been successfully updated.',
      type: SnackType.success,
    );
  }

  void onBeforeNav() {
    if (widget.closeModalOnNav) {
      Navigator.pop(context);
    }
  }

  void updateUserAccountLang() async {
    final userAuth = stateUser.userAuth;

    if (userAuth == null) {
      notifyLangSuccess();
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .update({
        'lang': stateUser.lang,
      });

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
