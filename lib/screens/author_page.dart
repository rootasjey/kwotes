import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/link_card.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/animation.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';

class AuthorPage extends StatefulWidget {
  final String id;

  AuthorPage({this.id});

  @override
  _AuthorPageState createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  Author author;
  List<Quote> quotes = [];

  bool areQuotesLoading = false;
  bool areQuotesLoaded = false;
  bool isLoading = false;

  double beginY = 100.0;
  double delay = 0.0;

  TextOverflow nameEllipsis = TextOverflow.ellipsis;

  @override
  void initState() {
    super.initState();
    delay = 0.0;
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        if (!isLoading && author == null) {
          return Container(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Icon(
                    Icons.sentiment_neutral,
                    size: 40.0,
                  ),
                ),

                Text(
                  "Sorry, no data found for the specified author"
                ),
              ],
            ),
          );
        }

        if (isLoading) {
          return LoadingAnimation(
            textTitle: 'Loading author...',
          );
        }

        return bodyData();
      }),
    );
  }

  Widget avatar() {
    if (author.urls.image != null && author.urls.image.length > 0) {
      return Material(
        elevation: 1.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: NetworkImage(author.urls.image),
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
                        image: NetworkImage(author.urls.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              );
            },
          ),
        ),
      );
    }

    return Material(
      elevation: 1.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Image.asset(
            'assets/images/user-${stateColors.iconExt}.png',
            width: 80.0,
          ),
        ),
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  height: 500.0,
                  width: 500.0,
                  child: Image(
                    image: AssetImage('assets/images/user-${stateColors.iconExt}.png',),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
          );
        },
      ),
    );
  }

  Widget bodyData() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollNotif) {
        if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
          return false;
        }

        if (!areQuotesLoading && !areQuotesLoaded) {
          if (quotes.length > 0) { return false; }

          areQuotesLoading = true;

          Firestore.instance
            .collection('quotes')
            .where('author.id', isEqualTo: widget.id)
            .limit(1)
            .getDocuments()
            .then((querySnap) {
              if (querySnap.documents.length == 0) { return; }

              querySnap.documents.forEach((element) {
                final data = element.data;
                data['id'] = element.documentID;
                quotes.add(Quote.fromJSON(data));
              });

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  areQuotesLoaded = true;
                  areQuotesLoading = false;
                });
              });
            }).catchError((error) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  areQuotesLoaded = true;
                  areQuotesLoading = false;
                });
              });
            });
        }

        return false;
      },
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                alignment: AlignmentDirectional.center,
                child: Column(
                  children: <Widget>[
                    hero(),

                    FadeInY(
                      beginY: beginY,
                      delay: 4.0,
                      child: summary(),
                    ),

                    FadeInY(
                      beginY: beginY,
                      delay: 5.0,
                      child: links(),
                    ),

                    if (areQuotesLoading)
                      Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: LinearProgressIndicator(),
                      ),

                    FadeInY(
                      beginY: beginY,
                      delay: 6.0,
                      child: mainQuote(),
                    ),
                  ],
                ),
              ),

              backButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget customLinkCard({
    String name,
    String url,
    String imageUrl,
  }) {

    delay += 1.0;

    return FadeInX(
      beginX: 50.0,
      delay: delay,
      child: LinkCard(
        name: name,
        url: url,
        imageUrl: imageUrl,
      ),
    );
  }

  Widget hero() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FadeInY(
            beginY: beginY,
            delay: 1.0,
            child: avatar(),
          ),

          FadeInY(
            beginY: beginY,
            delay: 2.0,
            child: name(),
          ),

          ControlledAnimation(
            delay: 2.seconds,
            duration: 1.seconds,
            tween: Tween(begin: 0.0, end: 100.0),
            builder: (_, value) {
              return SizedBox(
                width: value,
                child: Divider(height: 20.0,),
              );
            },
          ),

          FadeInY(
            beginY: beginY,
            delay: 3.0,
            child: job(),
          ),
        ],
      ),
    );
  }

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: FlatButton(
        onPressed: () {
          setState(() {
            nameEllipsis = nameEllipsis == TextOverflow.ellipsis ?
              TextOverflow.visible : TextOverflow.ellipsis;
          });
        },
        child: Text(
          author.name,
          overflow: nameEllipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget job() {
    return Opacity(
      opacity: .7,
      child: Text(
        author.job,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget mainQuote() {
    if (quotes.length > 0) {
      final quote = quotes.first;

      return Column(
        children: <Widget>[
          Divider(height: 50.0,),

          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                'Quote',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ),

          SizedBox(
            width: 100.0,
            child: Divider(),
          ),

          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0),
              child: createHeroQuoteAnimation(
                isMobile: true,
                quote: quote,
                screenWidth: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(padding: EdgeInsets.zero);
  }

  Widget summary() {
    return Column(
      children: <Widget>[
        Divider(),

        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Opacity(
            opacity: .6,
            child: Text(
              'SUMMARY',
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
          ),
        ),

        SizedBox(
          width: 100.0,
          child: Divider(),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 60.0,
          ),
          child: Text(
            author.summary,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w100,
              height: 1.5,
            ),
          ),
        ),

        Divider(height: 50.0,),
      ],
    );
  }

  Widget links() {
    final urls = author.urls;

    return SizedBox(
      height: 200.0,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          if (urls.wikipedia.isNotEmpty)
            Observer(
              builder: (_) {
                return customLinkCard(
                  name: 'Wikipedia',
                  url: urls.wikipedia,
                  imageUrl: 'assets/images/wikipedia-${stateColors.iconExt}.png',
                );
              },
            ),

          if (urls.website.isNotEmpty)
            customLinkCard(
              name: 'Website',
              url: urls.website,
              imageUrl: 'assets/images/world-globe.png',
            ),

          if (urls.amazon.isNotEmpty)
            customLinkCard(
              name: 'Amazon',
              url: urls.amazon,
              imageUrl: 'assets/images/amazon.png',
            ),

          if (urls.facebook.isNotEmpty)
            customLinkCard(
              name: 'Facebook',
              url: urls.facebook,
              imageUrl: 'assets/images/facebook.png',
            ),

          if (urls.netflix.isNotEmpty)
            customLinkCard(
              name: 'Netflix',
              url: urls.netflix,
              imageUrl: 'assets/images/netflix.png',
            ),

          if (urls.primeVideo.isNotEmpty)
            customLinkCard(
              name: 'Prime Video',
              url: urls.primeVideo,
              imageUrl: 'assets/images/prime-video.png',
            ),

          if (urls.twitch.isNotEmpty)
            customLinkCard(
              name: 'Twitch',
              url: urls.twitch,
              imageUrl: 'assets/images/twitch.png',
            ),

          if (urls.twitter.isNotEmpty)
            customLinkCard(
              name: 'Twitter',
              url: urls.twitter,
              imageUrl: 'assets/images/twitter.png',
            ),

          if (urls.youtube.isNotEmpty)
            customLinkCard(
              name: 'Youtube',
              url: urls.youtube,
              imageUrl: 'assets/images/youtube.png',
            ),
        ],
      ),
    );
  }

  Widget backButton() {
    return Positioned(
      left: 0.0,
      top: 0.0,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
      )
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnap = await Firestore.instance
        .collection('authors')
        .document(widget.id)
        .get();

      if (!docSnap.exists) {
        isLoading = false;
        return;
      }

      final data = docSnap.data;
      data['id'] = docSnap.documentID;

      setState(() {
        author = Author.fromJSON(data);

        nameEllipsis = author.name.length > 42 ?
          TextOverflow.ellipsis : TextOverflow.visible;

        isLoading = false;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }
}
