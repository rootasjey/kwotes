import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/add_to_list_button.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/animation.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/push_notifications.dart';
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
  bool hasFetchFav = false;

  @override
  void initState() {
    super.initState();
    fetchQuotidian();
    initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OrientationBuilder(
        builder: (context, orientation) {
          return body();
        },
      ),
    );
  }

  Widget body() {
    if (isLoading && quotidian == null) {
      return LoadingAnimation();
    }

    if (quotidian == null) {
      return errorView();
    }

    final topicColor = appTopicsColors.find(quotidian.quote.topics.first);
    final color = topicColor != null ?
      Color(topicColor.decimal) :
      Colors.white;

    return ListView(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                quoteName(
                  screenWidth: MediaQuery.of(context).size.width,
                ),

                authorDivider(color: color),

                FadeInY(
                  beginY: 50.0,
                  delay: 1.0,
                  child: authorName(),
                ),

                if (quotidian.quote.mainReference?.name != null &&
                  quotidian.quote.mainReference.name.length > 0)
                  FadeInY(
                    beginY: 100.0,
                    delay: 2.0,
                    child: referenceName(),
                  ),
              ],
            ),
          ),
        ),

        userActions(),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 200.0),
          child: MaterialButton(
            onPressed: () {
              FluroRouter.router.navigateTo(context, HomeRoute);
            },
            color: color,
            textColor: Colors.white,
            child: Icon(
              Icons.close,
              size: 36,
            ),
            padding: EdgeInsets.all(16),
            shape: CircleBorder(),
          ),
        ),
      ],
    );
  }

  Widget authorDivider({Color color}) {
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
          padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
          child: SizedBox(
            width: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget authorName() {
    return FlatButton(
      onPressed: () {
        final id = quotidian.quote.author.id;

        FluroRouter.router.navigateTo(
          context,
          AuthorRoute.replaceFirst(':id', id)
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Opacity(
          opacity: .8,
          child: Text(
            quotidian.quote.author.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
            ),
          ),
        )
      ),
    );
  }

  Widget errorView() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.warning, size: 80.0,),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Opacity(
              opacity: .8,
              child: Text(
                'Sorry, an unexpected error happended :(',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: FlatButton(
              onPressed: () => fetchQuotidian(),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: stateColors.primary,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
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
        FluroRouter.router.navigateTo(
          context,
          QuotePageRoute.replaceFirst(':id', quotidian.quote.id),
        );
      },
      child: createHeroQuoteAnimation(
        isMobile: true,
        quote: quotidian.quote,
        screenWidth: screenWidth,
      ),
    );
  }

  Widget referenceName() {
    final refName = quotidian.quote.mainReference.name;

    return FlatButton(
      onPressed: () {
        final id = quotidian.quote.mainReference.id;

        FluroRouter.router.navigateTo(
          context,
          ReferenceRoute.replaceFirst(':id', id)
        );
      },
      child: Opacity(
        opacity: .5,
        child: Text(
          refName.length > 65 ?
          '${refName.substring(0, 64)}...' :
          refName,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget userActions() {
    final quote = quotidian.quote;

    return Observer(
      builder: (_) {
        if (!hasFetchFav) {
          hasFetchFav = true;
          fetchIsFav();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: userState.isUserConnected ?
                  () async {
                    if (quote.starred) {
                      removeQuoteFromFav();
                      return;
                    }

                    addQuoteToFav();
                } : null,
                icon: quote.starred ?
                  Icon(Icons.favorite) :
                  Icon(Icons.favorite_border),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: IconButton(
                  onPressed: () async {
                    shareFromMobile(
                      context: context,
                      quote: quote,
                    );
                  },
                  icon: Icon(Icons.share),
                ),
              ),

              AddToListButton(
                quote: quote,
                isDisabled: !userState.isUserConnected,
              ),
            ],
          ),
        );
      }
    );
  }

  void addQuoteToFav() async {
    final quote = quotidian.quote;

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

  void fetchIsFav() async {
    quotidian.quote.starred = await isFavourite(quoteId: quotidian.quote.id);
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

  /// ?NOTE: This method is localted here
  /// because it needs a context containing a Navigator
  /// for notifications navigation.
  void initNotifications() {
    final userUid = appLocalStorage.getUserUid();

    PushNotifications.initialize(
      context: context,
      userUid: userUid,
    );
  }

  void removeQuoteFromFav() async {
    final quote = quotidian.quote;

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
