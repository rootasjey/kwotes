import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/add_to_list_button.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/full_page_error.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/topic_color.dart';
import 'package:memorare/utils/animation.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class QuotePage extends StatefulWidget {
  final String quoteId;

  QuotePage({this.quoteId});

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  bool isLoading;
  Quote quote;
  List<TopicColor> topicColors = [];

  FirebaseUser userAuth;

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return FullPageLoading(
        title: 'Loading quote...',
      );
    }

    if (quote == null) {
      return FullPageError(
        message: 'Error while loading the quote.',
      );
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height - 0.0,
              child: Padding(
                padding: EdgeInsets.all(70.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    backIcon(),

                    quoteName(
                      screenWidth: MediaQuery.of(context).size.width,
                    ),

                    animatedDivider(),

                    authorName(),

                    if (quote.mainReference.name.length > 0)
                      referenceName(),
                  ],
                ),
              ),
            ),

            userActions(),

            topicsList(),

            NavBackFooter(),
          ],
        );
      },
    );
  }

  Widget animatedDivider() {
    final topicColor = appTopicsColors.find(quote.topics.first);
    final color = topicColor != null ?
      Color(topicColor.decimal) :
      Colors.white;

    return ControlledAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 200.0),
      child: Divider(
          color: color,
          thickness: 2.0,
      ),
      builderWithChild: (context, child, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: SizedBox(
            width: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget authorName() {
    return ControlledAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 0.8),
      child: FlatButton(
        onPressed: () {
          final id = quote.author.id;

          FluroRouter.router.navigateTo(
            context,
            AuthorRoute.replaceFirst(':id', id)
          );
        },
        child: Text(
          quote.author.name,
          style: TextStyle(
            fontSize: 25.0,
          ),
        ),
      ),
      builderWithChild: (context, child, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Opacity(
            opacity: value,
            child: child,
          )
        );
      },
    );
  }

  Widget backIcon() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              FluroRouter.router.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          )
        ],
      ),
    );
  }

  Widget quoteName({double screenWidth}) {
    return createHeroQuoteAnimation(
      quote: quote,
      screenWidth: screenWidth,
    );
  }

  Widget referenceName() {
    return ControlledAnimation(
      delay: 2.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 0.6),
      child: FlatButton(
        onPressed: () {
          final id = quote.mainReference.id;

          FluroRouter.router.navigateTo(
            context,
            ReferenceRoute.replaceFirst(':id', id)
          );
        },
        child: Text(
          quote.mainReference.name,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
      builderWithChild: (context, child, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Opacity(
            opacity: value,
            child: child,
          )
        );
      },
    );
  }

  Widget topicsList() {
    if (topicColors.length == 0) {
      return Padding(padding: EdgeInsets.zero);
    }

    double count = 0;

    return Container(
      width: MediaQuery.of(context).size.width,
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 300,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 80.0,),
              scrollDirection: Axis.horizontal,
              children: topicColors.map((topic) {
                count += 1.0;

                return FadeInX(
                  delay: count,
                  beginX: 50.0,
                  child: TopicCardColor(
                    color: Color(topic.decimal),
                    name: topic.name,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget userActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: userAuth == null ?
              null : () async {
                if (quote.starred) {
                  removeQuoteFromFav();
                  return;
                }

                addQuoteToFav();
            },
            icon: quote.starred ?
              Icon(Icons.favorite) :
              Icon(Icons.favorite_border),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: IconButton(
              onPressed: () async {
                shareTwitter(quote: quote);
              },
              icon: Icon(Icons.share),
            ),
          ),

          AddToListButton(
            quote: quote,
            isDisabled: userAuth == null,
          ),
        ],
      ),
    );
  }

  void addQuoteToFav() async {
    setState(() { // Optimistic result
      quote.starred = true;
    });

    final result = await addToFavourites(
      context: context,
      quote: quote,
    );

    if (!result) {
      setState(() {
        quote.starred = false;
      });
    }
  }

  void fetchTopics() async {
    final _topicsColors = <TopicColor>[];

    for (String topicName in quote.topics) {
      final doc = await Firestore.instance
        .collection('topics')
        .document(topicName)
        .get();

      if (doc.exists) {
        final topic = TopicColor.fromJSON(doc.data);
        _topicsColors.add(topic);
      }
    }

    setState(() {
      topicColors = _topicsColors;
    });
  }

  void fetchQuote() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await Firestore.instance
        .collection('quotes')
        .document(widget.quoteId)
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = doc.data;
      data['id'] = doc.documentID;
      quote = Quote.fromJSON(data);

      await fetchIsFav();

      setState(() {
        isLoading = false;
      });

      fetchTopics();

    } catch (error) {
      setState(() {
        isLoading = false;
      });

      debugPrint(error);
    }
  }

  Future fetchIsFav() async {
    userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth != null) {
      final isFav = await isFavourite(
        userUid: userAuth.uid,
        quoteId: quote.id,
      );

      quote.starred = isFav;
    }
  }

  void removeQuoteFromFav() async {
    setState(() { // Optimistic result
      quote.starred = false;
    });

    final result = await removeFromFavourites(
      context: context,
      quote: quote,
    );

    if (!result) {
      setState(() {
        quote.starred = true;
      });
    }
  }
}
