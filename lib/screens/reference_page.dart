import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/link_card.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';

class ReferencePage extends StatefulWidget {
  final String id;

  ReferencePage({this.id});

  @override
  ReferencePageState createState() => ReferencePageState();
}

class ReferencePageState extends State<ReferencePage> {
  Reference reference;
  List<Quote> quotes = [];
  bool areQuotesLoading = false;
  bool areQuotesLoaded = false;

  bool isLoading = false;

  double delay = 0.0;
  final double beginY = 100.0;

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
        if (isLoading) {
          return LoadingAnimation(
            textTitle: 'Loading reference...',
          );
        }

        return body();
      }),
    );
  }

  Widget body() {
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
            .where('mainReference.id', isEqualTo: widget.id)
            .where('lang', isEqualTo: userState.lang)
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
            })
            .catchError((error) {
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
              reference == null ?
                Padding(
                  padding: const EdgeInsets.only(top: 150.0),
                  child: ErrorContainer(
                    message: 'Oops! There was an error while loading the reference',
                    onRefresh: () => fetch(),
                  ),
                ) :
                refBody(),

              backButton(),
            ],
          ),
        ],
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

          SizedBox(
            width: 100.0,
            child: Divider(height: 50.0,),
          ),

          FadeInY(
            beginY: beginY,
            delay: 3.0,
            child: types(),
          ),
        ],
      ),
    );
  }

  Widget refBody() {
    return Container(
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

          mainQuote(),
        ],
      ),
    );
  }

  Widget avatar() {
    final imageUrl = reference.urls.image;
    final imageUrlOk = imageUrl != null && imageUrl.length > 0;

    return SizedBox(
      width: 200,
      height: 250,
      child: Card(
        elevation: imageUrlOk ? 5.0 : 0.0,
        child: imageUrlOk ?
          Ink.image(
            image: NetworkImage(
              reference.urls.image,
            ),
            fit: BoxFit.cover,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Container(
                        child: Image(
                          image: NetworkImage(reference.urls.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                );
              },
            ),
          ) :
          Center(
            child: Text(
              reference.name.substring(0, 2).toUpperCase(),
              style: TextStyle(
                fontSize: 50.0,
              ),
            ),
          ),
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

  Widget links() {
    final urls = reference.urls;

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

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: FlatButton(
        onPressed: () {
          setState(() {
            nameEllipsis = nameEllipsis == TextOverflow.ellipsis ?
              TextOverflow.visible : TextOverflow.ellipsis;
          });
        },
        child: Text(
          reference.name,
          textAlign: TextAlign.center,
          overflow: nameEllipsis,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
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

          InkWell(
            onTap: () {
              FluroRouter.router.navigateTo(
                context,
                QuotePageRoute.replaceFirst(':id', quote.id),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 100.0,
              ),
              child: FlatButton(
                onPressed: () {
                  FluroRouter.router.navigateTo(
                    context,
                    QuotePageRoute.replaceFirst(':id', quote.id)
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    quote.name,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(padding: EdgeInsets.zero);
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
        padding: const EdgeInsets.only(right: 17.0),
      ),
    );
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
            reference.summary,
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

  Widget types() {
    final type = reference.type;

    return Column(
      children: <Widget>[
        Opacity(
          opacity: .7,
          child: Text(
            type.primary,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),

        if (type.secondary != null && type.secondary.length > 0)
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                type.secondary,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnap  = await Firestore.instance
        .collection('references')
        .document(widget.id)
        .get();

      if (!docSnap.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = docSnap.data;
      data['id'] = docSnap.documentID;

      setState(() {
        reference = Reference.fromJSON(data);

        nameEllipsis = reference.name.length > 42 ?
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
