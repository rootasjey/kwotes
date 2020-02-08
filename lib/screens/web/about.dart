import 'package:flutter/material.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0),
          child: InkWell(
            onTap: () {
              FluroRouter.router.navigateTo(context, HomeRoute);
            },
            borderRadius: BorderRadius.circular(50.0),
            child: Image(
              image: AssetImage('assets/images/icon-small.png'),
              width: 90.0,
              height: 90.0,
            ),
          ),
        ),

        SizedBox(
          width: 600.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Opacity(
                opacity: .8,
                child: Text(
                  'What is Memorare?',
                  style: TextStyle(
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Opacity(
                opacity: .6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    'Memorare is a quotes application and service. Its main purpose is to deliver you one meaningful quote each day. The subject can be as diverse as funny, philosophical, introspective, motivational. In addition, you can browse quotes by topics, authors, references and use the search feature.',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),

              Opacity(
                opacity: .8,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: Text(
                    'How is it different from existing quotes app?',
                    style: TextStyle(
                      fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Opacity(
                  opacity: .6,
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                          text: 'After a thorough case study, Memorare is the only app which regroup the following features: ',
                          children: [
                            TextSpan(text: '\n\n• Multi-patform (Android, iOS, Web)'),
                            TextSpan(text: '\n• Multi-languages (English & French)'),
                            TextSpan(text: '\n• You can add your own quotes to the app'),
                            TextSpan(text: '\n• A clean user interface'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Opacity(
                opacity: .8,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: Text(
                    'Who is behind this project?',
                    style: TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Opacity(
                opacity: .6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    'A french developer who like quotes.',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(padding: const EdgeInsets.only(bottom: 300.0),),
      ],
    );
  }
}
