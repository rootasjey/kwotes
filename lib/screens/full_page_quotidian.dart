import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/web/add_to_list_button.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
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
  bool hasFetchFav = false;

  @override
  void initState() {
    super.initState();
    fetchQuotidian();
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
      return LoadingComponent();
    }

    if (quotidian == null) {
      return emptyContainer();
    }

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

                authorDivider(),

                authorName(),
              ],
            ),
          ),
        ),

        userActions(),

        if (quotidian.quote.mainReference?.name != null &&
          quotidian.quote.mainReference.name.length > 0)
          referenceSection(),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 200.0),
          child: MaterialButton(
            onPressed: () {
              FluroRouter.router.navigateTo(context, HomeRoute);
            },
            color: stateColors.primary,
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

  Widget authorDivider() {
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

                FluroRouter.router.navigateTo(
                  context,
                  AuthorRoute.replaceFirst(':id', id)
                );
              },
              child: Text(
                quotidian.quote.author.name,
                textAlign: TextAlign.center,
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

  Widget referenceCard() {
    final refName = quotidian.quote.mainReference.name;

    return SizedBox(
      width: 170,
      height: 220,
      child: Card(
        elevation: 2.0,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: () {
            final id = quotidian.quote.mainReference.id;

            FluroRouter.router.navigateTo(
              context,
              ReferenceRoute.replaceFirst(':id', id)
            );
          },
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  refName.length > 65 ?
                  '${refName.substring(0, 64)}...' :
                  refName,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),

              Positioned(
                right: 10.0,
                bottom: 10.0,
                child: Opacity(
                  opacity: .6,
                  child:
                  Image.asset(
                    'assets/images/textbook-${stateColors.iconExt}.png',
                    width: 40.0,
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget referenceDivider() {
    final width = MediaQuery.of(context).size.width;

    return ControlledAnimation(
      delay: 2.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: width),
      builder: (_, value) {
        return SizedBox(
          width: value,
          child: Divider(thickness: 2.0,),
        );
      },
    );
  }

  Widget referenceSection() {
    return Column(
      children: <Widget>[
        referenceDivider(),

        FadeInY(
          beginY: 100.0,
          delay: 1.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'Reference',
              ),
            ),
          ),
        ),

        FadeInY(
          beginY: 100.0,
          delay: 1.2,
          child: SizedBox(
            width: 100.0,
            child: Divider(),
          ),
        ),

        FadeInY(
          beginY: 100.0,
          delay: 1.4,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 30.0,
              bottom: 60.0,
            ),
            child: referenceCard(),
          ),
        ),

        referenceDivider(),
      ],
    );
  }

  Widget userActions() {
    final quote = quotidian.quote;

    return Observer(
      builder: (_) {
        if (!hasFetchFav) {
          print('fetch fav');
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
