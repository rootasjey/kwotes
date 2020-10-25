import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/actions/favourites.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/add_to_list_button.dart';
import 'package:figstyle/components/full_page_loading.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/quotidian.dart';
import 'package:figstyle/utils/animation.dart';
import 'package:figstyle/screens/author_page.dart';
import 'package:figstyle/screens/reference_page.dart';
import 'package:figstyle/screens/quote_page.dart';
import 'package:mobx/mobx.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

String _prevLang;

class QuotidianPage extends StatefulWidget {
  final bool noAuth;

  QuotidianPage({
    this.noAuth = false,
  });

  @override
  _QuotidianPageState createState() => _QuotidianPageState();
}

class _QuotidianPageState extends State<QuotidianPage> {
  bool isPrevFav = false;
  bool hasFetchedFav = false;
  bool isLoading = false;
  bool isMenuOn = false;

  Quotidian quotidian;

  ReactionDisposer disposeFav;
  ReactionDisposer disposeLang;

  TextDecoration dashboardLinkDecoration = TextDecoration.none;

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
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 70.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            quoteActions(),
                            Expanded(
                              child: quoteName(
                                screenWidth: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ],
                        ),
                        animatedDivider(),
                        authorName(),
                        if (quotidian.quote.mainReference?.name != null &&
                            quotidian.quote.mainReference.name.length > 0)
                          referenceName(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget animatedDivider() {
    final topicColor = appTopicsColors.find(quotidian.quote.topics.first);
    final color = topicColor != null ? Color(topicColor.decimal) : Colors.white;

    return ControlledAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 200.0),
      child: Divider(
        color: color,
        thickness: 2.0,
      ),
      builderWithChild: (context, child, value) {
        return SizedBox(
          width: value,
          child: child,
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

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AuthorPage(
                              id: id,
                            )));
                  },
                  child: Text(
                    quotidian.quote.author.name,
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                )));
      },
    );
  }

  Widget emptyContainer() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.warning,
            size: 40.0,
          ),
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

  Widget quoteActions() {
    return Observer(builder: (context) {
      if (!userState.isUserConnected) {
        return Padding(
          padding: EdgeInsets.zero,
        );
      }

      return Column(
        children: <Widget>[
          IconButton(
            onPressed: () async {
              if (isPrevFav) {
                removeQuotidianFromFav();
                return;
              }

              addQuotidianToFav();
            },
            icon:
                isPrevFav ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: IconButton(
              onPressed: () async {
                shareQuote(context: context, quote: quotidian.quote);
              },
              icon: Icon(Icons.share),
            ),
          ),
          AddToListButton(
            quote: quotidian.quote,
          ),
        ],
      );
    });
  }

  Widget quoteName({double screenWidth}) {
    return Padding(
      padding: const EdgeInsets.only(left: 60.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => QuotePage(quoteId: quotidian.quote.id)));
        },
        child: createHeroQuoteAnimation(
          quote: quotidian.quote,
          screenWidth: screenWidth,
        ),
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

          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ReferencePage(id: id)));
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
            ));
      },
    );
  }

  void addQuotidianToFav() async {
    setState(() {
      // Optimistic result
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
    if (quotidian == null) {
      return;
    }

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
    setState(() {
      // Optimistic result
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
