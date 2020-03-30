import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 200.0,
            width: 700.0,
            child: Card(
              color: Color(0xFF45D09E),
              child: InkWell(
                onTap: () async {
                  const url = 'mailto:feedback@outofcontext.app?subject=[Outofcontext%20Web]%20Feedback';
                  await launch(url);
                },
                child: Container(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Icon(Icons.email, color: Colors.white, size: 55.0,),
                          )
                        ],
                      ),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Opacity(
                              opacity: .5,
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),

                          Text(
                            'We would love to hear from you',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ),
                          ),
                          Text(
                            'feedback@outofcontext.app',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 200.0,
            width: 700.0,
            child: Card(
              color: Color(0xFF64C7FF),
              child: InkWell(
                onTap: () async {
                  const url = 'https://twitter.com/intent/tweet?via=outofcontextapp';
                  await launch(url);
                },
                child: Container(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Icon(IconsMore.twitter, color: Colors.white, size: 55.0,),
                          )
                        ],
                      ),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Opacity(
                              opacity: .5,
                              child: Text(
                                'Twitter',
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),

                          Text(
                            'You can contact us on Twitter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ),
                          ),
                          Text(
                            '@outofcontext',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ),
          ),
        ),

        NavBackFooter(),
      ],
    );
  }
}
