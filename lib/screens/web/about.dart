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
              ...whatIs(context),

              ...differences(),

              ...whoIs(context),

              ...whoIs2(context),

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
            'HOW IS IT DIFFERENT FROM EXISTSING QUOTES APPS?',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0),
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
          padding: const EdgeInsets.only(top: 120.0, bottom: 30.0),
          child: Text(
            'THANKS',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
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

      Opacity(
        opacity: .6,
        child: FlatButton(
          onPressed: () {
            launch('https://orioniconlibrary.com');
          },
          child: Text(
            '• https://orioniconlibrary.com',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> whatIs(BuildContext context) {
    return [
      Ink.image(
        image: NetworkImage(
          'https://raw.githubusercontent.com/outofcontextapp/app/master/screenshots/home_quote.png',
        ),
        height: 380.0,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Container(
                    child: Image(image: NetworkImage('https://raw.githubusercontent.com/outofcontextapp/app/master/screenshots/home_quote.png'),),
                  ),
                );
              }
            );
          },
        ),
      ),

      Center(
        child: FlatButton(
          onPressed: () async {
            await launch('https://raw.githubusercontent.com/outofcontextapp/app/master/screenshots/home_quote.png');
          },
          child: Opacity(
            opacity: .6,
            child: Text('Out Of Context home page'),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Opacity(
          opacity: .8,
          child: Text(
            'WHAT IS OUT OF CONTEXT (OOC)?',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Text(
            'Out Of Context is a quotes application and service. Its main purpose is to deliver you one meaningful quote each day. The subject can be as diverse as funny, philosophical, introspective, or motivational. In addition, you can browse quotes by topics, authors, references and use the search feature.',
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
            'WHO IS BEHIND THIS PROJECT?',
            style: TextStyle(
              fontSize: 30.0,
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
            "Hi, I'm Jérémie CORPINOT, a freelance developer who lives in France.",
            style: TextStyle(
              fontSize: 20.0,
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
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            "I'm originally from Guadeloupe and one day I traveled to Paris to study Architecture. But that didn't work out very weel as I never passed the entrance exam. So, I went to the Versailles University where I was graduated with a Master of Computer Sciences.",
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
            "I love drawings, video games, heroic-fantasy books, to name a few. I started the freelancer journey in June, 2019 because I wanted to do what really matter to me.",
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
          padding: const EdgeInsets.only(top: 120.0),
          child: Text(
            "DEV STORY",
            style: TextStyle(
              fontSize: 30.0,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            "A few years ago, I was developping on the Windows Phone platform (RIP) improving my skills in mobile development. I loved quotes, a lot, and I wanted an easy way to save them. I had my own idea.",
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
            "The idea was to wake up every morning with a funny or motivational quote and I wasn't satisfied with existing apps, so I started to build my own.",
            style: TextStyle(
              fontSize: 20.0,
              height: 1.5,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> whoIs2(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 120.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Ink.image(
                image: NetworkImage(
                  'https://raw.githubusercontent.com/rootasjey/citations365/master/lockscreen.png',
                ),
                width: 230.0,
                height: 400.0,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Container(
                            child: Image(image: NetworkImage('https://raw.githubusercontent.com/rootasjey/citations365/master/lockscreen.png'),),
                          ),
                        );
                      }
                    );
                  },
                ),
              ),

              FlatButton(
                onPressed: () async {
                  await launch('https://raw.githubusercontent.com/rootasjey/citations365/master/lockscreen.png');
                },
                child: Opacity(
                  opacity: .6,
                  child: Text('Citations 365 lockscreen quote'),
                ),
              ),
            ],
          ),
        ),
      ),

      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: <Widget>[
              Opacity(
                opacity: .6,
                child: Text(
                  "I created a first prototype for Windows Phone:",
                  style: TextStyle(
                    fontSize: 20.0,
                    height: 1.5,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: FlatButton(
                  onPressed: () async {
                    await launch('https://github.com/rootasjey/citations365');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'CITATIONS 365',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      ),

      Padding(
        padding: const EdgeInsets.only(top: 120.0),
        child: Column(
          children: <Widget>[
            Ink.image(
              image: NetworkImage(
                'https://raw.githubusercontent.com/rootasjey/citations365-8/master/citations.windows.jpg',
              ),
              height: 380.0,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Image(image: NetworkImage('https://raw.githubusercontent.com/rootasjey/citations365-8/master/citations.windows.jpg'),),
                        ),
                      );
                    }
                  );
                },
              ),
            ),

            FlatButton(
                onPressed: () async {
                  await launch('https://raw.githubusercontent.com/rootasjey/citations365-8/master/citations.windows.jpg');
                },
                child: Opacity(
                  opacity: .6,
                  child: Text('Citations 365 for PC & teblet'),
                ),
              ),
          ],
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Text(
            "Then made a Windows 8 version for PC and tablet.",
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
            "Sadly, a few months later, I quit the Windows Phone Platform for Android & iOS for lack of support, so I stop maintaining Citations 365.",
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
            "When I started my freelancer's journey it was a evidence that I had to start with the quotes project. I wanted to conclude definitvely with this idea.",
            style: TextStyle(
              fontSize: 20.0,
              height: 1.5,
            ),
          ),
        ),
      ),

      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 70.0),
          child: FlatButton(
            onPressed: () async {
              await launch('https://github.com/outofcontextapp/app');
            },
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: <Widget>[
                  Image.asset('assets/images/app-icon-64.png'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'OUT OF CONTEXT',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      ),

      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            "A new name and a new framework later, I release this web app with a mobile app, wich over-achieve my goal of what I wanted to build.",
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
