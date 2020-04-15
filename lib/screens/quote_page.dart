import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/animation.dart';
import 'package:memorare/components/add_to_list_button.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:share/share.dart';
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
  Color topicColor;

  bool isLoading = false;

  FirebaseUser userAuth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (quote != null) { return; }

    fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        if (isLoading) {
          return LoadingAnimation(
            title: 'Loading quote...',
          );
        }

        if (!isLoading && quote == null) {
          return ErrorContainer(
            message: "Sorry, we couldn't load the quote. Try again later.",
          );
        }

        topicColor = quote.topics.length > 0 ?
          ThemeColor.topicColor(quote.topics.first) :
          ThemeColor.primary;

        return ListView(
          padding: EdgeInsets.only(bottom: 70.0),
          children: <Widget>[
            Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    quoteName(),

                    Padding(padding: EdgeInsets.only(top: 40.0),),

                    authorName(),

                    referenceName(),

                    topics(),

                    actionButtons(),
                  ],
                ),

                backButton(),
              ],
            ),
          ],
        );
      }),
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
                  final RenderBox box = context.findRenderObject();
                  final sharingText = '${quote.name} - ${quote.author.name}';

                  Share.share(
                    sharingText,
                    subject: 'Out Of Context',
                    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                  );
                },
              ),
              if (userState.isUserConnected)
                AddToListButton(
                  context: context,
                  quoteId: quote.id,
                  size: 40.0,
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
      left: 5.0,
      top: 20.0,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,),
        ),
      )
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

          // await Firestore.instance
          //   .collection('users')
          //   .document()

          // final booleanMessage = await Mutations.unstar(context, quote.id);

          // if (!booleanMessage.boolean) {
          //   setState(() { // rollback
          //     quote.starred = true;
          //   });

          //   Flushbar(
          //     duration: Duration(seconds: 2),
          //     backgroundColor: ThemeColor.error,
          //     message: booleanMessage.message,
          //   )..show(context);
          // }
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

        // final booleanMessage = await Mutations.star(context, quote.id);

        // if (!booleanMessage.boolean) {
        //   setState(() { // rollback
        //     quote.starred = false;
        //   });

        //   Flushbar(
        //     duration: Duration(seconds: 2),
        //     backgroundColor: ThemeColor.error,
        //     message: booleanMessage.message,
        //   )..show(context);
        // }
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
      color: topicColor,
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
                color: Colors.white,
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

  void fetchQuote() async {
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

      setState(() {
        quote = Quote.fromJSON(data);
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
