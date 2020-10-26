import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/components/footer.dart';
import 'package:figstyle/components/main_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  final titleStyle = TextStyle(
    fontSize: 20.0,
  );

  final paragraphStyle = TextStyle(
    fontSize: 18.0,
    height: 1.5,
  );

  final titleOpacity = 0.9;
  final paragraphOpacity = 0.6;
  final captionOpacity = 0.6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          MainAppBar(
            title: 'About',
            automaticallyImplyLeading: true,
            showUserMenu: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 200.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  children: <Widget>[
                    whatIs(context),
                    differences(),
                    whoIs(context),
                    whoIs2(context),
                    creditsSection(),
                  ],
                ),
              ]),
            ),
          ),
          if (kIsWeb && MediaQuery.of(context).size.width > 700.0)
            SliverList(
              delegate: SliverChildListDelegate([
                Footer(),
              ]),
            ),
        ],
      ),
    );
  }

  Widget differences() {
    return SizedBox(
      width: 600.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 120.0),
            child: Opacity(
              opacity: titleOpacity,
              child: Text(
                'FEATURES',
                style: titleStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Opacity(
              opacity: paragraphOpacity,
              child: Text(
                '👇 Available now:',
                style: paragraphStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Opacity(
              opacity: paragraphOpacity,
              child: Text(
                '• Multi-patform: Android, iOS, Web\n• Multi-languages: English & French\n• You can add your own quotes to the app\n• A nice user interface\n• And more',
                style: paragraphStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: Opacity(
              opacity: paragraphOpacity,
              child: Text(
                '🚀 Future development:',
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                '• API\n• Fitbit app\n• Chrome/Firefox extension\n• Desktop app widget',
                style: paragraphStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget creditsSection() {
    return SizedBox(
      width: 600.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: titleOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0, bottom: 30.0),
              child: Text(
                'CREDITS',
                style: titleStyle,
              ),
            ),
          ),
          FlatButton(
            onPressed: () => launch('https://icons8.com'),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('💄'),
                ),
                Opacity(
                  opacity: paragraphOpacity,
                  child: Text(
                    'Icons by Icons8',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FlatButton(
            onPressed: () => launch('https://iconmonstr.com'),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('💄'),
                ),
                Opacity(
                  opacity: paragraphOpacity,
                  child: Text(
                    'Icons by iconmonstr',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FlatButton(
            onPressed: () => launch('https://orioniconlibrary.com'),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('💄'),
                ),
                Opacity(
                  opacity: paragraphOpacity,
                  child: Text(
                    'Icons by Orion Icon Librairy',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FlatButton(
            onPressed: () =>
                launch('https://www.flaticon.com/authors/pixel-perfect'),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('💄'),
                ),
                Opacity(
                  opacity: paragraphOpacity,
                  child: Text(
                    'Icons by Pixel Perfect',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FlatButton(
            onPressed: () => launch('https://previewed.app/'),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('📷'),
                ),
                Opacity(
                  opacity: paragraphOpacity,
                  child: Text(
                    'Mobile app screenshots created with Previewed',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget whatIs(BuildContext context) {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(
        top: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Ink.image(
            image: AssetImage(
              'assets/images/app-icon-512.png',
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
                          child: Image(
                            image: AssetImage(
                              'assets/images/app-icon-412.png',
                            ),
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
          Center(
            child: FlatButton(
              onPressed: null,
              child: Opacity(
                opacity: captionOpacity,
                child: Text('App text icon'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Opacity(
              opacity: titleOpacity,
              child: Text(
                'THE CONCEPT',
                style: titleStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Text(
                'fig.style is a quotes application and service. Its main purpose is to deliver you one meaningful quote each day. There are several categories like: fun, philosophy, and motivation. You can also browse quotes by topics, authors, references or search them.',
                style: paragraphStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget whoIs(BuildContext context) {
    return SizedBox(
      width: 600.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: titleOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Text(
                'THE AUTHOR',
                style: titleStyle,
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
                                child: Image(
                                  image: AssetImage(
                                      'assets/images/jeje-profile.jpg'),
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                "I'm Jérémie CORPINOT, a freelance developer living in France.",
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "I'm originally from Guadeloupe and one day I traveled to Paris to study Architecture. But that didn't work out very weel as I never passed the entrance exam. So, I went to Versailles University where I was graduated with a Master in Computer Sciences.",
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "I love drawings, video games, heroic-fantasy books, to name a few. I started my freelancer journey in June, 2019 in order to work on what really matters.",
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: titleOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Text("THE STORY", style: titleStyle),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "A few years ago, I was developping on the Windows Phone platform (RIP), improving my skills in mobile development. I loved quotes and I didn't find a suitable app for my needs.",
                style: paragraphStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Opacity(
              opacity: paragraphOpacity,
              child: Text(
                "This is where I decided to build my own. The idea was to make the app send me a notification so I could wake up every morning with a funny or motivational quote.",
                style: paragraphStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20.0,
            ),
            child: Opacity(
              opacity: paragraphOpacity,
              child: Text(
                "For the data, I was scrapping the content of the Evene website. And only french was available as a language.",
                style: paragraphStyle,
              ),
            ),
          ),
          FlatButton.icon(
            onPressed: () async {
              await launch('http://evene.lefigaro.fr/');
            },
            icon: Icon(Icons.link),
            label: Text('http://evene.lefigaro.fr/'),
          ),
        ],
      ),
    );
  }

  Widget whoIs2(BuildContext context) {
    return SizedBox(
      width: 600.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                                  child: Image(
                                    image: NetworkImage(
                                        'https://raw.githubusercontent.com/rootasjey/citations365/master/lockscreen.png'),
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      await launch(
                          'https://raw.githubusercontent.com/rootasjey/citations365/master/lockscreen.png');
                    },
                    child: Opacity(
                      opacity: captionOpacity,
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
                      opacity: paragraphOpacity,
                      child: Text(
                        "I created a first prototype for Windows Phone:",
                        style: paragraphStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: FlatButton(
                        onPressed: () async {
                          await launch(
                              'https://github.com/rootasjey/citations365');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'CITATIONS 365',
                            style: titleStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
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
                                child: Image(
                                  image: NetworkImage(
                                      'https://raw.githubusercontent.com/rootasjey/citations365-8/master/citations.windows.jpg'),
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ),
                FlatButton(
                  onPressed: () async {
                    await launch(
                        'https://raw.githubusercontent.com/rootasjey/citations365-8/master/citations.windows.jpg');
                  },
                  child: Opacity(
                    opacity: captionOpacity,
                    child: Text('Citations 365 for PC & tablet'),
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Text(
                "Then I made a Windows 8 version for PC and tablet.",
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "Sadly, we all know how WP ended up, so I migrated to Android, and I stopped the development of Citations 365.",
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "When I started my freelancer's journey, I needed to fill up my portfolio and I had time. So I wanted to rebuild the quotes project on Android, iOS & Web. This time I would build a fullstack application.",
                style: paragraphStyle,
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
                            'fig.style',
                            style: paragraphStyle,
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "A new name and a new framework (Flutter) learned later, I released this web app with its mobile version, while over-achieving my initial goal.",
                style: paragraphStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
