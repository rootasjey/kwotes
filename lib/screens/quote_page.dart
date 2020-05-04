import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/web/add_to_list_button.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/animation.dart';
import 'package:memorare/types/quote.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';

class QuotePage extends StatefulWidget {
  final String id;

  QuotePage({this.id});

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  Quote quote;
  Color quoteColor;
  bool isLoading = false;

  @override
  initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: EdgeInsets.only(bottom: 70.0),
          children: <Widget>[
            Stack(
              children: <Widget>[
                body(),
                backButton(),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget body() {
    if (isLoading) {
      return LoadingAnimation(
        title: 'Loading quote...',
      );
    }

    if (!isLoading && quote == null) {
      return errorView();
    }

    return Column(
      children: <Widget>[
        quoteName(),

        Padding(padding: EdgeInsets.only(top: 40.0),),

        authorName(),

        referenceName(),

        topics(),

        actionButtons(),
      ],
    );
  }

  Widget actionButtons() {
    return Observer(
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.symmetric(horizontal: 50.0),
                iconSize: 30.0,
                icon: Icon(Icons.share,),
                onPressed: () {
                  shareFromMobile(
                    context: context,
                    quote: quote,
                  );
                },
              ),
              if (userState.isUserConnected)
                AddToListButton(
                  quote: quote,
                ),

              if (userState.isUserConnected)
                favButton(),
            ],
          ),
        );
      },
    );
  }

  Widget authorName() {
    final author = quote.author;

    return ControlledAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 0.8),
      child: FlatButton(
        onPressed: () {
          final id = author.id;

          FluroRouter.router.navigateTo(
            context,
            AuthorRoute.replaceFirst(':id', id)
          );
        },
        child: Text(
          author.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
      builderWithChild: (context, child, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 40.0),
          child: Opacity(
            opacity: value,
            child: child,
          )
        );
      },
    );
  }

  Widget backButton() {
    return Positioned(
      left: 30.0,
      top: 20.0,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: getFontColor(quoteColor),
          ),
        ),
      )
    );
  }

  Widget errorView() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 200.0,
        left: 30.0,
        right: 30.0,
      ),
      child: ErrorContainer(
        iconSize: 80.0,
        message: "Sorry, we couldn't load the quote. Try again later.",
        onRefresh: () => fetch(),
      ),
    );
  }

  Widget favButton() {
    if (quote.starred) {
      return IconButton(
        padding: EdgeInsets.all(30.0),
        iconSize: 40.0,
        icon: Icon(Icons.favorite,),
        onPressed: () async {
          setState(() { // optimistic
            quote.starred = false;
          });

          final success = await addToFavourites(
            context: context,
            quote: quote,
          );

          if (!success) {
            setState(() {
              quote.starred = true;
            });
          }
        },
      );
    }

    return IconButton(
      padding: EdgeInsets.symmetric(horizontal: 50.0),
      iconSize: 30.0,
      icon: Icon(Icons.favorite_border,),
      onPressed: () async {
        setState(() { // optimistic
          quote.starred = true;
        });

        final success = await removeFromFavourites(
          context: context,
          quote: quote,
        );

        if (!success) {
          setState(() {
            quote.starred = false;
          });
        }
      },
    );
  }

  Widget quoteName() {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 40.0,
      ),
      color: quoteColor,
      height: size.height,
      width: size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: createHeroQuoteAnimation(
              isMobile: true,
              quote: quote,
              screenWidth: size.width,
              style: TextStyle(
                color: getFontColor(quoteColor),
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget referenceName() {
    if (quote.references == null || quote.references.length == 0) {
      return Padding(padding: EdgeInsets.zero,);
    }

    final reference = quote.references.first;

    return InkWell(
      onTap: () {
        FluroRouter.router.navigateTo(
          context,
          ReferenceRoute.replaceFirst(':id', reference.id),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              reference.name,
              style: TextStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget topics() {
    final topics = quote.topics;
   final topicsDefined = topics != null && topics.length > 0;

    return topicsDefined ?
      Column(
        children: <Widget>[
          Divider(),
          Padding(padding: const EdgeInsets.only(top: 50.0)),

          SizedBox(
            height: 220.0,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics.elementAt(index);
                final topicColor = appTopicsColors.find(topic);

                return FadeInX(
                  beginX: 100.0,
                  endX: 0.0,
                  delay: index.toDouble(),
                  child: TopicCardColor(
                    size: 80.0,
                    elevation: 6.0,
                    color: Color(topicColor.decimal),
                    name: topic,
                    displayName: topic,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(),
        ],
      ) :
      Padding(padding: EdgeInsets.zero,);
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnap = await Firestore.instance
        .collection('quotes')
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

      quote = Quote.fromJSON(data);

      if (quote.topics.length > 0) {
        final tc = appTopicsColors.find(quote.topics.first);
        quoteColor = tc != null ? Color(tc.decimal) : stateColors.primary;
      } else {
        quoteColor = stateColors.primary;
      }

      setState(() {
        isLoading = false;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  Color getFontColor(Color color) {
    if (color == null) {
      return Colors.white;
    }

    int above200 = 0;

    if (color.blue > 200)   { above200++; }
    if (color.green > 200)  { above200++; }
    if (color.red > 200)    { above200++; }

    if (above200 > 1) { return Color(0xFF303030); }
    return Colors.white;
  }
}
