import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:figstyle/components/image_hero.dart';
import 'package:figstyle/screens/changelog.dart';
import 'package:figstyle/screens/tos.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/components/footer.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  final titleStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
  );

  final paragraphStyle = TextStyle(
    fontSize: 18.0,
    height: 1.5,
  );

  final titleOpacity = 0.9;
  final paragraphOpacity = 0.6;
  final captionOpacity = 0.6;

  final maxWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          DesktopAppBar(
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
                    appIconImage(context),
                    otherLinks(context),
                    whatIs(context),
                    features(),
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
              delegate: SliverChildListDelegate(
                [
                  Footer(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget appIconImage(BuildContext context) {
    final size = MediaQuery.of(context).size.width < 500.0 ? 280.0 : 380.0;

    return Container(
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 40.0,
      ),
      width: maxWidth,
      child: Column(
        children: [
          Center(
            child: OpenContainer(
              closedColor: Colors.transparent,
              closedElevation: 0.0,
              closedBuilder: (context, openContainer) {
                return Container(
                  width: size,
                  height: size,
                  child: Ink.image(
                    height: size,
                    width: size,
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/app-icon-512.png'),
                    child: InkWell(
                      onTap: openContainer,
                    ),
                  ),
                );
              },
              openBuilder: (context, callback) {
                return ImageHero(
                  imageProvider: AssetImage('assets/images/app-icon-512.png'),
                );
              },
            ),
          ),
          Center(
            child: FlatButton(
              onPressed: null,
              child: Opacity(
                opacity: captionOpacity,
                child: Text('App large icon'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget features() {
    return SizedBox(
      width: maxWidth,
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
              opacity: 1.0,
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
              opacity: 1.0,
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

  Widget creditItem({
    @required String textTitle,
    VoidCallback onPressed,
    Widget leading,
  }) {
    return FlatButton(
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          if (leading != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: leading,
            ),
          Expanded(
            child: Opacity(
              opacity: paragraphOpacity,
              child: Text(
                textTitle,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget creditsSection() {
    return SizedBox(
      width: maxWidth,
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
          creditItem(
            textTitle: 'Icons by Icons8',
            onPressed: () => launch('https://icons8.com'),
            leading: Text('💄'),
          ),
          creditItem(
            textTitle: 'Icons by iconmonstr',
            onPressed: () => launch('https://iconmonstr.com'),
            leading: Text('💄'),
          ),
          creditItem(
            textTitle: 'Icons by Orion Icon Library',
            onPressed: () => launch('https://orioniconlibrary.com'),
            leading: Text('💄'),
          ),
          creditItem(
            textTitle: 'Icons by Pixel Perfect',
            onPressed: () =>
                launch('https://www.flaticon.com/authors/pixel-perfect'),
            leading: Text('💄'),
          ),
          creditItem(
            textTitle: 'Illustrations by Natasha Remarchuk from Icons8',
            onPressed: () => launch('https://icons8.com/'),
            leading: Text('🖼️'),
          ),
          creditItem(
            textTitle: 'Mobile app screenshots created with Previewed',
            onPressed: () => launch('https://previewed.app/'),
            leading: Text('📷'),
          ),
        ],
      ),
    );
  }

  Widget otherLinks(context) {
    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: Text('Changelog'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Changelog())),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Terms of service'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Tos())),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('GitHub'),
              trailing: Icon(Icons.open_in_new),
              onTap: () => launch(Constants.appGithubUrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget whatIs(BuildContext context) {
    return Container(
      width: maxWidth,
      padding: const EdgeInsets.only(
        top: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
      width: maxWidth,
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
              child: OpenContainer(
                closedColor: Colors.transparent,
                closedElevation: 0.0,
                closedBuilder: (context, openContainer) {
                  return Material(
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
                        onTap: openContainer,
                      ),
                    ),
                  );
                },
                openBuilder: (context, callback) {
                  return ImageHero(
                    imageProvider: AssetImage('assets/images/jeje-profile.jpg'),
                  );
                },
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
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 120.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  OpenContainer(
                    closedColor: Colors.transparent,
                    closedBuilder: (context, openContainer) {
                      return Container(
                        width: 230.0,
                        height: 400.0,
                        child: Ink.image(
                          width: 230.0,
                          height: 400.0,
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            'https://raw.githubusercontent.com/rootasjey/citations365/master/lockscreen.png',
                          ),
                          child: InkWell(
                            onTap: openContainer,
                          ),
                        ),
                      );
                    },
                    openBuilder: (context, callback) {
                      return ImageHero(
                        imageProvider: NetworkImage(
                          'https://raw.githubusercontent.com/rootasjey/citations365/master/lockscreen.png',
                        ),
                      );
                    },
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
                Center(
                  child: OpenContainer(
                    closedColor: Colors.transparent,
                    closedBuilder: (context, openContainer) {
                      return Container(
                        height: 200.0,
                        width: 320.0,
                        child: Ink.image(
                          height: 200.0,
                          width: 320.0,
                          image: NetworkImage(
                            'https://raw.githubusercontent.com/rootasjey/citations365-8/master/citations.windows.jpg',
                          ),
                          child: InkWell(
                            onTap: openContainer,
                          ),
                        ),
                      );
                    },
                    openBuilder: (context, callback) {
                      return ImageHero(
                        imageProvider: NetworkImage(
                          'https://raw.githubusercontent.com/rootasjey/citations365-8/master/citations.windows.jpg',
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: FlatButton(
                    onPressed: () async {
                      await launch(
                          'https://raw.githubusercontent.com/rootasjey/citations365-8/master/citations.windows.jpg');
                    },
                    child: Opacity(
                      opacity: captionOpacity,
                      child: Text('Citations 365 for PC & tablet'),
                    ),
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
