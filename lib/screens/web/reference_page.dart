import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/full_page_error.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/horizontal_card.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/utils/router.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferencePage extends StatefulWidget {
  final String id;

  ReferencePage({this.id});

  @override
  _ReferencePageState createState() => _ReferencePageState();
}

class _ReferencePageState extends State<ReferencePage> {
  final beginY    = 50.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  Reference reference;
  Quote quote;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchReference();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return FadeInY(
        beginY: beginY,
        child: FullPageLoading(title: 'Loading reference...'),
      );
    }

    if (!isLoading && reference == null) {
      return FadeInY(
        beginY: beginY,
        child: FullPageError(
          message: 'An error occurred while loading reference.'
        ),
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(60.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            FluroRouter.router.pop(context);
                          },
                          icon: Icon(Icons.arrow_back,),
                        )
                      ],
                    ),

                    FadeInY(
                      beginY: beginY,
                      delay: delay + (0 * delayStep),
                      child: Padding(
                        padding: EdgeInsets.only(top: 100.0),
                        child: avatar(),
                      ),
                    ),

                    FadeInY(
                      beginY: beginY,
                      delay: delay + (1 * delayStep),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          reference.name,
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    ControlledAnimation(
                      delay: 1.seconds,
                      duration: 1.seconds,
                      tween: Tween(begin: 0.0, end: 100.0),
                      builder: (_, value) {
                        return SizedBox(
                          width: value,
                          child: Divider(
                            thickness: 1.0,
                            height: 50.0,
                          ),
                        );
                      },
                    ),

                    FadeInY(
                      beginY: beginY,
                      delay: delay + (2 * delayStep),
                      child: Opacity(
                        opacity: .8,
                        child: Text(
                          reference.type.primary,
                          style: TextStyle(
                          ),
                        ),
                      ),
                    ),

                    if (reference.type.secondary != null && reference.type.secondary.length > 0)
                      FadeInY(
                        beginY: beginY,
                        delay: delay + (3 * delayStep),
                        child: Opacity(
                          opacity: .8,
                          child: Text(
                            reference.type.secondary,
                            style: TextStyle(
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              ),
            ],
          ),
        ),

        Divider(
          thickness: 1.0,
        ),

        summary(),

        quoteCard(),

        externalLinks(),

        NavBackFooter(),
      ],
    );
  }

  Widget avatar() {
    if (reference.urls.image != null && reference.urls.image.length > 0) {
      return SizedBox(
        width: 200.0,
        height: 250.0,
        child: Card(
          child: Ink.image(
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
                        height: 500.0,
                        width: 500.0,
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
                    image: AssetImage('assets/images/textbook-${stateColors.iconExt}.png',),
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

  Widget summary() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Opacity(
            opacity: .6,
            child: Text(
              'SUMMARY'
            ),
          )
        ),

        SizedBox(
          width: 100,
          child: Divider(thickness: 1.0,)
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 100.0
          ),
          child: SizedBox(
            width: 600.0,
            child: Opacity(
              opacity: .7,
              child: Text(
                reference.summary,
                style: TextStyle(
                  fontSize: 25.0,
                  height: 1.5,
                )
              ),
            ),
          )
        ),
      ],
    );
  }

  Widget externalLinks() {
    final children = <Widget>[];

    if (reference.urls.wikipedia != null &&
      reference.urls.wikipedia.length > 0) {

      children.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 200.0,
            height: 240.0,
            child: Card(
              child: InkWell(
                onTap: () {
                  launch(reference.urls.wikipedia);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Icon(
                          IconsMore.wikipedia_w,
                          size: 30.0,
                        ),
                      ),
                      Text(
                        'Wikipedia',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      );
    }

    if (reference.urls.website != null &&
      reference.urls.website.length > 0) {

      children.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 200.0,
            height: 240.0,
            child: Card(
              child: InkWell(
                onTap: () {
                  launch(reference.urls.website);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Icon(
                          IconsMore.earth,
                          size: 30.0,
                        ),
                      ),
                      Text(
                        'Website',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ),
        )
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'EXTERNAL LINKS'
              ),
            )
          ),

          SizedBox(
            width: 100,
            child: Divider(thickness: 1.0,)
          ),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Wrap(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget quoteCard() {
    if (quote == null) {
      return Padding(padding: EdgeInsets.zero,);
    }

    return Container(
      child: Column(
        children: <Widget>[
          Divider(
            thickness: 1.0,
          ),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'QUOTES'
              ),
            )
          ),

          SizedBox(
            width: 100,
            child: Divider(thickness: 1.0,)
          ),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: HorizontalCard(
              quoteId: quote.id,
              quoteName: quote.name,
              authorId: quote.author.id,
              authorName: quote.author.name,
            ),
          ),

          Divider(
            thickness: 1.0,
          ),
        ],
      ),
    );
  }

  void fetchQuote() async {
    if (reference == null) { return; }

    try {
      final snapshot = await Firestore.instance
        .collection('quotes')
        .where('mainReference.name', isEqualTo: reference.name)
        .limit(1)
        .getDocuments();

      snapshot.documents.forEach((doc) {
        quote = Quote.fromJSON(doc.data);
      });

      setState(() {});

    } catch (error) {
    }
  }

  void fetchReference() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await Firestore.instance
        .collection('references')
        .document(widget.id)
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      setState(() {
        reference = Reference.fromJSON(doc.data);
        isLoading = false;
      });

      fetchQuote();

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }
}
