import 'package:flutter/material.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),

        SizedBox(
          width: 600.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...whatIs(),

              ...differences(),

              ...whoIs(context),

              ...whoIs2(),

              ...thanks(),
            ],
          ),
        ),

        NavBackFooter(),
      ],
    );
  }

  List<Widget> differences() {
    return [
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

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            'After a thorough case study, Out Of Context is the only app which regroup the following features: ',
            style: TextStyle(
              fontSize: 20.0,
              height: 1.5,
            ),
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            '• Multi-patform (Android, iOS, Web)\n• Multi-languages (English & French)\n• You can add your own quotes to the app\n• A nice user interface\n• A future API',
            style: TextStyle(
              fontSize: 20.0,
              height: 1.5,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> thanks() {
    return <Widget>[
      Opacity(
        opacity: .8,
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Text(
            'Resources',
            style: TextStyle(
              fontSize: 50.0,
            ),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
        child: Text(
          'Illustrations:',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: FlatButton(
          onPressed: () {
            launch('https://icons8.com');
          },
          child: Text(
            '• https://icons8.com',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> whatIs() {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Opacity(
          opacity: .8,
          child: Text(
            'What is Out Of Context (OOC) ?',
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
            'Out OF Context is a quotes application and service. Its main purpose is to deliver you one meaningful quote each day. The subject can be as diverse as funny, philosophical, introspective, or motivational. In addition, you can browse quotes by topics, authors, references and use the search feature.',
            style: TextStyle(
              fontSize: 20.0,
              height: 1.5,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> whoIs(BuildContext context) {
    return [
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

      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: Material(
            elevation: 1.0,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: Ink.image(
              image: AssetImage('assets/images/jeje-profile.jpg'),
              fit: BoxFit.cover,
              width: 200.0,
              height: 200.0,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Image(image: AssetImage('assets/images/jeje-profile.jpg'),),
                        ),
                      );
                    }
                  );
                },
              ),
            ),
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            'Jérémie CORPINOT, a french developer who likes quotes.',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            "A few years ago, I was developping on the Windows Phone platform (RIP) improving my skills in mobile development. I was fascinated by catchy phrases of some people and I wanted an easy way to save them. It's when the idea emerged.",
            style: TextStyle(
              fontSize: 20.0,
              height: 1.5,
            ),
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            "Plus I wanted to wake up every morning with a funny or motivational quote and I wasn't satified with existing apps so I started to build my own.",
            style: TextStyle(
              fontSize: 20.0,
              height: 1.5,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> whoIs2() {
    return [
      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Text(
            "'Citations 365 was alive!'",
            style: TextStyle(
              fontSize: 40.0,
              height: 1.5,
            ),
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            "A few months past, I quit the Windows Phone Platform for Android & iOS for lack of support, and I stop to maintain Citations 365.",
            style: TextStyle(
              fontSize: 20.0,
              height: 1.5,
            ),
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            "Fast forward 2 years later, I quit my job. I have a lot of projects I want to try and build. No existing quote app satisfies me on Android or iOS, so I decide to try building this long life project as a first goal.",
            style: TextStyle(
              fontSize: 20.0,
              height: 1.5,
            ),
          ),
        ),
      ),
    ];
  }
}
