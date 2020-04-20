import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/add_to_list_button.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/animation.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:mobx/mobx.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

String _prevLang;

class FullPageQuotidian extends StatefulWidget {
  @override
  _FullPageQuotidianState createState() => _FullPageQuotidianState();
}

class _FullPageQuotidianState extends State<FullPageQuotidian> {
  bool isPrevFav = false;
  bool hasFetchedFav = false;
  bool isLoading = false;

  Quotidian quotidian;

  ReactionDisposer disposeFav;
  ReactionDisposer disposeLang;

  @override
  void initState() {
    super.initState();

    disposeLang = autorun((_) {
      if (quotidian != null && _prevLang == userState.lang) {
        return;
      }

      _prevLang = userState.lang;
      fetch();
    });

    disposeFav = autorun((_) {
      final updatedAt = userState.updatedFavAt;
      fetchIsFav(updatedAt: updatedAt);
    });
  }

  @override
  void dispose() {
    if (disposeLang != null) {
      disposeLang();
    }

    if (disposeFav != null) {
      disposeFav();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && quotidian == null) {
      return FullPageLoading(
        title: 'Loading quotidian...',
      );
    }

    if (quotidian == null) {
      return emptyContainer();
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height - 50.0,
              child: Padding(
                padding: EdgeInsets.all(70.0),
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

            userSection(),
          ],
        );
      },
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

                FluroRouter.router.navigateTo(
                  context,
                  AuthorRoute.replaceFirst(':id', id)
                );
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
        FluroRouter.router.navigateTo(
          context,
          QuotePageRoute.replaceFirst(':id', quotidian.quote.id),
        );
      },
      child: createHeroQuoteAnimation(
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
          final id = quotidian.quote.mainReference.id;

          FluroRouter.router.navigateTo(
            context,
            ReferenceRoute.replaceFirst(':id', id)
          );
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

  Widget signinButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              FluroRouter.router.navigateTo(
                context,
                SigninRoute,
              );
            },
            shape: RoundedRectangleBorder(
              side: BorderSide(color: stateColors.primary),
            ),
            color: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Sign in',
              ),
            ),
          )
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
            onPressed: () async {
              if (isPrevFav) {
                removeQuotidianFromFav();
                return;
              }

              addQuotidianToFav();
            },
            icon: isPrevFav ?
              Icon(Icons.favorite) :
              Icon(Icons.favorite_border),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: IconButton(
              onPressed: () async {
                shareTwitter(quote: quotidian.quote);
              },
              icon: Icon(Icons.share),
            ),
          ),

          AddToListButton(quote: quotidian.quote,),
        ],
      ),
    );
  }

  Widget userSection() {
    return Observer(builder: (context) {
      if (userState.isUserConnected) {
        if (!hasFetchedFav) { fetchIsFav(); }

        hasFetchedFav = true;

        return userActions();
      }

      hasFetchedFav = false;
      return signinButton();
    });
  }

  void addQuotidianToFav() async {
    setState(() { // Optimistic result
      isPrevFav = true;
    });

    final result = await addToFavourites(
      context: context,
      quotidian: quotidian,
    );

    if (!result) {
      setState(() {
        isPrevFav = false;
      });
    }
  }

  void fetchIsFav({DateTime updatedAt}) async {
    final isCurrentFav = await isFavourite(
      quoteId: quotidian.quote.id,
    );

    if (isPrevFav != isCurrentFav) {
      isPrevFav = isCurrentFav;
      setState(() {});
    }
  }

  void fetch() async {
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
        .document('${now.year}:$month:$day:$_prevLang')
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

  void removeQuotidianFromFav() async {
    setState(() { // Optimistic result
      isPrevFav = false;
    });

    final result = await removeFromFavourites(
      context: context,
      quotidian: quotidian,
    );

    if (!result) {
      setState(() {
        isPrevFav = true;
      });
    }
  }
}
