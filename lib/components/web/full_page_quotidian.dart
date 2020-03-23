import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/add_to_list_button.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_connection.dart';
import 'package:memorare/state/user_lang.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/animation.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';
import 'package:mobx/mobx.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

Quotidian _quotidian;
String _prevLang;
bool _isConnected;
bool _isFav = false;

class FullPageQuotidian extends StatefulWidget {
  @override
  _FullPageQuotidianState createState() => _FullPageQuotidianState();
}

class _FullPageQuotidianState extends State<FullPageQuotidian> {
  bool isLoading = false;
  FirebaseUser userAuth;

  ReactionDisposer disposeLang;

  @override
  void initState() {
    super.initState();

    disposeLang = autorun((_) {
      if (_quotidian != null && _prevLang == appUserLang.current) {
        return;
      }

      fetchQuotidian();
    });
  }

  @override
  void dispose() {
    if (disposeLang != null) {
      disposeLang();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return FullPageLoading(
        title: 'Loading quotidian...',
      );
    }

    if (!isLoading && _quotidian == null) {
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

                    if (_quotidian.quote.mainReference?.name != null &&
                      _quotidian.quote.mainReference.name.length > 0)
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
    final topicColor = appTopicsColors.find(_quotidian.quote.topics.first);
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
                final id = _quotidian.quote.author.id;

                FluroRouter.router.navigateTo(
                  context,
                  AuthorRoute.replaceFirst(':id', id)
                );
              },
              child: Text(
                _quotidian.quote.author.name,
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
          QuotePageRoute.replaceFirst(':id', _quotidian.quote.id),
        );
      },
      child: createHeroQuoteAnimation(
        quote: _quotidian.quote,
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
          final id = _quotidian.quote.author.id;

          FluroRouter.router.navigateTo(
            context,
            ReferenceRoute.replaceFirst(':id', id)
          );
        },
        child: Text(
          _quotidian.quote.mainReference.name,
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
            child: Text(
              'Sign in',
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
              if (_isFav) {
                removeQuotidianFromFav();
                return;
              }

              addQuotidianToFav();
            },
            icon: _isFav ?
              Icon(Icons.favorite) :
              Icon(Icons.favorite_border),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: IconButton(
              onPressed: () async {
                shareTwitter(quote: _quotidian.quote);
              },
              icon: Icon(Icons.share),
            ),
          ),

          AddToListButton(quote: _quotidian.quote,),
        ],
      ),
    );
  }

  Widget userSection() {
    return Observer(builder: (context) {
      if (_isConnected != isUserConnected.value) {
        fetchIsFav();
      }

      if (isUserConnected.value) {
        _isConnected = true;
        return userActions();
      }

      _isConnected = false;
      return signinButton();
    });
  }

  void addQuotidianToFav() async {
    setState(() { // Optimistic result
      _isFav = true;
    });

    final result = await addToFavourites(
      context: context,
      quotidian: _quotidian,
    );

    if (!result) {
      setState(() {
        _isFav = false;
      });
    }
  }

  void fetchIsFav() async {
    userAuth = userAuth ?? await FirebaseAuth.instance.currentUser();

    if (userAuth == null) {
      return;
    }

    final isFav = await isFavourite(
      userUid: userAuth.uid,
      quoteId: _quotidian.quote.id,
    );

    if (_isFav != isFav) {
      _isFav = isFav;
      setState(() {});
    }

    if (!_isConnected) {
      setUserConnected();
    }
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
      final doc = await FirestoreApp.instance
        .collection('quotidians')
        .doc('${now.year}:$month:$day:${appUserLang.current}')
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      _prevLang = appUserLang.current;

      setState(() {
        _quotidian = Quotidian.fromJSON(doc.data());
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
      _isFav = false;
    });

    final result = await removeFromFavourites(
      context: context,
      quotidian: _quotidian,
    );

    if (!result) {
      setState(() {
        _isFav = true;
      });
    }
  }
}
