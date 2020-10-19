import 'package:flutter/material.dart';
import 'package:memorare/utils/icons_more_icons.dart';
import 'package:memorare/components/main_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MainAppBar(
            title: "Contact",
            automaticallyImplyLeading: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 80.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Column(
                  children: [
                    emailBlock(),
                    twitterBlock(),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardLink({
    Color color = const Color(0xFF45D09E),
    Widget icon,
    Function onTap,
    String socialAccount,
    String subTitle,
    @required String textTitle,
  }) {
    final horPadding = MediaQuery.of(context).size.width < 700.0 ? 20 : 80.0;
    final height = MediaQuery.of(context).size.width < 400.0 ? 400 : 200.0;
    final double fontSize =
        MediaQuery.of(context).size.width < 600.0 ? 16.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horPadding,
        vertical: 24.0,
      ),
      child: SizedBox(
        height: height,
        width: 700.0,
        child: Card(
          color: color,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (icon != null) icon,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Opacity(
                            opacity: 0.5,
                            child: Text(
                              textTitle,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: 0.7,
                          child: Text(
                            subTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                        Text(
                          socialAccount,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget emailBlock() {
    return cardLink(
      onTap: () async {
        const url =
            'mailto:feedback@outofcontext.app?subject=[Outofcontext%20Web]%20Feedback';
        await launch(url);
      },
      icon: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.email,
          color: Colors.white,
          size: 55.0,
        ),
      ),
      color: Color(0xFF45D09E),
      textTitle: 'Email',
      subTitle: 'We would love to hear from you',
      socialAccount: 'feedback@outofcontext.app',
    );
  }

  Widget twitterBlock() {
    return cardLink(
      onTap: () async {
        const url = 'https://twitter.com/intent/tweet?via=outofcontextapp';
        await launch(url);
      },
      icon: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          IconsMore.twitter,
          color: Colors.white,
          size: 55.0,
        ),
      ),
      color: Color(0xFF64C7FF),
      textTitle: 'Twitter',
      subTitle: 'You can contact us on Twitter',
      socialAccount: '@outofcontext',
    );
  }
}
