import 'package:auto_route/auto_route.dart';

import 'package:fig_style/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:fig_style/state/user.dart';
import 'package:fig_style/utils/language.dart';
import 'package:fig_style/utils/snack.dart';
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
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 10.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              'DEVELOPERS',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        basicButtonLink(
          textValue: 'Documentation',
        ),
        basicButtonLink(
          textValue: 'API References',
        ),
        basicButtonLink(
          textValue: 'API Status',
        ),
        basicButtonLink(
          textValue: 'GitHub',
          onTap: () async {
            onBeforeNav();
            await launch('https://github.com/rootasjey/fig.style');
          },
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
            left: 10.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              'LANGUAGE',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        basicButtonLink(
          textValue: 'English',
          onTap: () {
            onBeforeNav();
            Language.setLang(Language.en);
            updateUserAccountLang();
          },
        ),
        basicButtonLink(
          textValue: 'Français',
          onTap: () {
            onBeforeNav();
            Language.setLang(Language.fr);
            updateUserAccountLang();
          },
        ),
      ],
    );
  }

  Widget basicButtonLink({Function onTap, @required String textValue}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 6.0,
        ),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            // side: BorderSide(),
          ),
        ),
        child: Opacity(
          opacity: onTap != null ? 0.7 : 0.3,
          child: Text(
            textValue,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget resourcesLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 10.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              'RESOURCES',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        basicButtonLink(
          textValue: 'About',
          onTap: () {
            onBeforeNav();
            context.router.root.push(AboutRoute());
          },
        ),
        basicButtonLink(
          textValue: 'Contact',
          onTap: () {
            onBeforeNav();
            context.router.root.push(ContactRoute());
          },
        ),
        basicButtonLink(
          textValue: 'Privacy & Terms',
          onTap: () {
            onBeforeNav();
            context.router.root.push(TosRoute());
          },
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
    } else if (widget.autoNavToHome) {
      context.router.root.navigate(HomeRoute());
    }

    Snack.s(
      context: context,
      message: 'Your language has been successfully updated.',
    );
  }

  void onBeforeNav() {
    if (widget.closeModalOnNav) {
      context.router.pop();
    }
  }

  void updateUserAccountLang() async {
    final userAuth = stateUser.userAuth;

    if (userAuth == null) {
      notifyLangSuccess();
      return;
    }
  }
}
