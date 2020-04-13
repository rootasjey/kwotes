import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/button_link.dart';
import 'package:memorare/components/loading.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchAuthor();
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
          return LoadingComponent(
            title: 'Loading author...',
            padding: EdgeInsets.all(30.0),
          );
        }

        return authorBody();
      }),
    );
  }

  Widget authorBody() {
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
                      child: job(),
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

                    FadeInY(
                      beginY: beginY,
                      delay: 6.0,
                      child: authorQuote(),
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

  Widget avatar() {
    return Padding(
      padding: EdgeInsets.only(top: 70.0),
      child: InkWell(
        onTap: () {
          if (author.urls.image == null ||
            author.urls.image.length == 0) {
            return;
          }

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  child: Image(image: NetworkImage(author.urls.image),),
                ),
              );
            }
          );
        },
        child: author.urls.image != null && author.urls.image.length > 0 ?
          CircleAvatar(
            radius: 90.0,
            backgroundColor: stateColors.primary,
            backgroundImage: NetworkImage(author.urls.image)
          ):
          CircleAvatar(
            radius: 90.0,
            backgroundColor: stateColors.primary,
            child: Text(
              author.name.substring(0, 2).toUpperCase(),
              style: TextStyle(
                fontSize: 50.0,
              ),
            ),
          ),
      )
    );
  }

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Text(
        author.name,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget job() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Opacity(
        opacity: .7,
        child: Text(
          author.job,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget summary() {
    final padding = author.summary != null && author.summary.length > 0 ?
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0):
      EdgeInsets.zero;

    return Padding(
      padding: padding,
      child: Text(
        author.summary,
        style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w100,
          height: 1.5,
        ),
      ),
    );
  }

  Widget buttonsLinks() {
    final wikiUrlDefined = author.urls.wikipedia!= null && author.urls.wikipedia.length > 0;
    final urlDefined = author.urls.website != null && author.urls.website.length > 0;

    return Column(
      children: <Widget>[
        if (wikiUrlDefined)
          ButtonLink(
            icon: Icon(IconsMore.wikipedia_w, color: Colors.white,),
            padding: EdgeInsets.only(top: 10.0),
            text: 'Open Wikipedia',
            url: author.urls.wikipedia,
          ),

        if (urlDefined)
          ButtonLink(
            icon: Icon(IconsMore.earth, color: Colors.white),
            padding: EdgeInsets.only(top: 10.0),
            text: 'Open website',
            url: author.urls.website,
          ),
      ],
    );
  }

  Widget authorQuote() {
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
                padding: const EdgeInsets.symmetric(vertical: 60.0),
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

  void fetchAuthor() async {
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
