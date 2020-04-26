import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/button_link.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/utils/animation.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';

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

  final double beginY = 100.0;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        if (isLoading) {
          return LoadingComponent(
            title: 'Loading reference...',
            padding: EdgeInsets.all(30.0),
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
                    onPressed: () => fetch(),
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

  Widget refBody() {
    return Container(
      alignment: AlignmentDirectional.center,
      child: Column(
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

          FadeInY(
            beginY: beginY,
            delay: 3.0,
            child: type(),
          ),

          FadeInY(
            beginY: beginY,
            delay: 4.0,
            child: summary(),
          ),

          FadeInY(
            beginY: beginY,
            delay: 5.0,
            child: buttonsLinks(),
          ),

          if (areQuotesLoading)
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: LinearProgressIndicator(),
            ),

          ControlledAnimation(
            delay: 2.seconds,
            duration: 1.seconds,
            tween: Tween(begin: 0.0, end: MediaQuery.of(context).size.width),
            builder: (_, value) {
              return SizedBox(
                width: value,
                child: Divider(),
              );
            },
          ),

          mainQuote(),
        ],
      ),
    );
  }

  Widget avatar() {
    final imageUrl = reference.urls.image;

    return Padding(
      padding: EdgeInsets.only(top: 70.0),
      child: InkWell(
        onTap: () {
          if (imageUrl == null || imageUrl.length == 0) {
            return;
          }

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  child: Image(image: NetworkImage(imageUrl),),
                ),
              );
            }
          );
        },
        child: imageUrl != null && imageUrl.length > 0 ?
          SizedBox(
            width: 200,
            height: 200,
            child: Card(
              elevation: 5.0,
              color: ThemeColor.primary,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              )
            ),
          ):
          SizedBox(
            width: 200,
            height: 200,
            child: Card(
              elevation: 5.0,
              child: Center(
                child: Text(
                  reference.name.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    fontSize: 50.0,
                  ),
                ),
              )
            ),
          ),
      )
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

  Widget buttonsLinks() {
    final urls = reference.urls;

    final hasWiki = urls.wikipedia != null && urls.wikipedia.length > 0;
    final hasWebsite = urls.website != null && urls.website.length > 0;

    return Column(
      children: <Widget>[
        if (hasWiki)
          ButtonLink(
            icon: Icon(IconsMore.wikipedia_w, color: Colors.white,),
            padding: EdgeInsets.only(top: 10.0),
            text: 'Open Wikipedia',
            url: urls.wikipedia,
          ),

        if (hasWebsite)
          ButtonLink(
            icon: Icon(IconsMore.earth, color: Colors.white),
            padding: EdgeInsets.only(top: 10.0),
            text: 'Open website',
            url: urls.website,
          ),
      ],
    );
  }

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Text(
        reference.name,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget mainQuote() {
    if (quotes.length > 0) {
      final quote = quotes.first;

      return Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Column(
          children: <Widget>[
            Divider(),

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

            GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 60.0,
                  horizontal: 5.0,
                ),
                child: createHeroQuoteAnimation(
                  isMobile: true,
                  quote: quote,
                  screenWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(padding: EdgeInsets.zero);
  }

  Widget summary() {
    final summary = reference.summary;
    final padding = summary != null && summary.length > 0 ?
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0):
      EdgeInsets.zero;

    return Padding(
      padding: padding,
      child: Text(
        summary,
        style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w100,
          height: 1.5,
        ),
      ),
    );
  }

  Widget type() {
    final type = reference.type;

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Opacity(
            opacity: .7,
            child: Text(
              type.primary,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.0,
              ),
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
