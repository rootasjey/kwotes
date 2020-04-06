import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/animation.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';

class FullPageQuotidian extends StatefulWidget {
  @override
  _FullPageQuotidianState createState() => _FullPageQuotidianState();
}

class _FullPageQuotidianState extends State<FullPageQuotidian> {
  bool isPrevFav = false;
  bool hasFetchedFav = false;
  bool isLoading = false;
  FirebaseUser userAuth;

  Quotidian quotidian;

  @override
  void initState() {
    super.initState();
    fetchQuotidian();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && quotidian == null) {
      return LoadingComponent();
    }

    if (quotidian == null) {
      return emptyContainer();
    }

    return Scaffold(
        body: OrientationBuilder(
        builder: (context, orientation) {
          return ListView(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height - 50.0,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      quoteName(
                        screenWidth: MediaQuery.of(context).size.width,
                      ),

                      animatedDivider(),

                      authorName(),

                      if (quotidian.quote.mainReference?.name != null &&
                        quotidian.quote.mainReference.name.length > 0)
                        referenceName(),
                    ],
                  ),
                ),
              ),

              // userSection(),
            ],
          );
        },
      ),
    );
  }

  Widget animatedDivider() {
    final topicColor = appTopicsColors.find(quotidian.quote.topics.first);
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
      builder: (context, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () {
                final id = quotidian.quote.author.id;

                // FluroRouter.router.navigateTo(
                //   context,
                //   AuthorRoute.replaceFirst(':id', id)
                // );
              },
              child: Text(
                quotidian.quote.author.name,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            )
          )
        );
      },
    );
  }

  Widget emptyContainer() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.warning, size: 40.0,),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Sorry, an unexpected error happended :(',
              style: TextStyle(
                fontSize: 35.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget quoteName({double screenWidth}) {
    return GestureDetector(
      onTap: () {
        // FluroRouter.router.navigateTo(
        //   context,
        //   QuotePageRoute.replaceFirst(':id', quotidian.quote.id),
        // );
      },
      child: createHeroQuoteAnimation(
        isMobile: true,
        quote: quotidian.quote,
        screenWidth: screenWidth,
      ),
    );
  }

  Widget referenceName() {
    return ControlledAnimation(
      delay: 2.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 0.6),
      child: GestureDetector(
        onTap: () {
          final id = quotidian.quote.author.id;

          // FluroRouter.router.navigateTo(
          //   context,
          //   ReferenceRoute.replaceFirst(':id', id)
          // );
        },
        child: Text(
          quotidian.quote.mainReference.name,
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

  void fetchQuotidian() async {
    setState(() {
      isLoading = true;
    });

    final now = DateTime.now();

    String month = now.month.toString();
    month = month.length == 2 ? month : '0$month';

    String day = now.day.toString();
    day = day.length == 2 ? day : '0$day';

    try {
      final doc = await Firestore.instance
        .collection('quotidians')
        .document('${now.year}:$month:$day:en')
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      setState(() {
        quotidian = Quotidian.fromJSON(doc.data);
        isLoading = false;
      });

    } catch (error, stackTrace) {
      debugPrint('error => $error');
      debugPrint(stackTrace.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

}
