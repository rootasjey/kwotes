import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/components/quote_row_with_actions.dart';
import 'package:memorare/components/simple_appbar.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/enums.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';

class Favourites extends StatefulWidget {
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  bool descending = true;
  bool hasNext = true;
  bool isFabVisible = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  int limit = 30;

  final pageRoute = FavouritesRoute;
  List<Quote> quotes = [];

  final scrollController = ScrollController();

  var lastDoc;

  @override
  initState() {
    super.initState();
    getSavedOrder();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                scrollController.animateTo(
                  0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: stateColors.primary,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: body(),
    );
  }

  Widget body() {
    return OrientationBuilder(
      builder: (context, orientation) {
        final screenWidth = MediaQuery.of(context).size.width;

        return NotificationListener(
          onNotification: (ScrollNotification scrollNotif) {
            // FAB visibility
            if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
              setState(() {
                isFabVisible = false;
              });
            } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
              setState(() {
                isFabVisible = true;
              });
            }

            // Load more scenario
            if (scrollNotif.metrics.pixels <
                scrollNotif.metrics.maxScrollExtent - 100.0) {
              return false;
            }

            if (hasNext && !isLoadingMore) {
              fetchMore();
            }

            return false;
          },
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              appBar(),
              listContent(screenWidth: screenWidth),
            ],
          ),
        );
      },
    );
  }

  Widget appBar() {
    return SimpleAppBar(
      textTitle: 'Favourites',
      subHeader: Observer(
        builder: (context) {
          return Wrap(
            spacing: 10.0,
            children: <Widget>[
              FadeInY(
                beginY: 10.0,
                delay: 2.0,
                child: ChoiceChip(
                  label: Text(
                    'First added',
                    style: TextStyle(
                      color:
                          !descending ? Colors.white : stateColors.foreground,
                    ),
                  ),
                  selected: !descending,
                  selectedColor: stateColors.primary,
                  onSelected: (selected) {
                    if (!descending) {
                      return;
                    }

                    descending = false;
                    fetch();

                    appLocalStorage.setPageOrder(
                      descending: descending,
                      pageRoute: pageRoute,
                    );
                  },
                ),
              ),
              FadeInY(
                beginY: 10.0,
                delay: 2.5,
                child: ChoiceChip(
                  label: Text(
                    'Last added',
                    style: TextStyle(
                      color: descending ? Colors.white : stateColors.foreground,
                    ),
                  ),
                  selected: descending,
                  selectedColor: stateColors.primary,
                  onSelected: (selected) {
                    if (descending) {
                      return;
                    }

                    descending = true;
                    fetch();

                    appLocalStorage.setPageOrder(
                      descending: descending,
                      pageRoute: pageRoute,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget listContent({double screenWidth}) {
    if (isLoading) {
      return loadingView();
    }

    if (quotes.length == 0) {
      return emptyView();
    }

    return sliverQuotesList();
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 2.0,
          beginY: 50.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: EmptyContent(
              icon: Opacity(
                opacity: .8,
                child: Icon(
                  Icons.favorite_border,
                  size: 60.0,
                  color: Color(0xFFFF005C),
                ),
              ),
              title: "You've no favourites quotes at this moment",
              subtitle: 'You can add them with the ❤️ button',
            ),
          ),
        ),
      ]),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: LoadingAnimation(
            textTitle: 'Loading your favourites...',
          ),
        ),
      ]),
    );
  }

  Widget sliverQuotesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final quote = quotes.elementAt(index);

          return QuoteRowWithActions(
            quote: quote,
            quoteId: quote.quoteId,
            type: QuoteRowActionType.favourites,
            onBeforeRemoveFromFavourites: () {
              setState(() {
                // optimistic
                quotes.removeAt(index);
              });
            },
            onAfterRemoveFromFavourites: (bool success) {
              if (!success) {
                setState(() {
                  quotes.insert(index, quote);
                });
              }

              userState.updateFavDate();
            },
          );
        },
        childCount: quotes.length,
      ),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    quotes.clear();

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isLoading = false;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final snapshot = await Firestore.instance
          .collection('users')
          .document(userAuth.uid)
          .collection('favourites')
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          isLoading = false;
          hasNext = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.documents.last;

      setState(() {
        isLoading = false;
        hasNext = limit == snapshot.documents.length;
      });
    } catch (error) {
      debugPrint(error.toString());

      showSnack(
        context: context,
        message: 'There was an issue while fetching your favourites.',
        type: SnackType.error,
      );
    }
  }

  void fetchMore() async {
    setState(() {
      isLoadingMore = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
      }

      final snapshot = await Firestore.instance
          .collection('users')
          .document(userAuth.uid)
          .collection('favourites')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.documents.last;

      setState(() {
        isLoadingMore = false;
        hasNext = limit == snapshot.documents.length;
      });
    } catch (error) {
      debugPrint(error.toString());

      showSnack(
        context: context,
        message: 'There was an issue while fetching your favourites.',
        type: SnackType.error,
      );
    }
  }

  void getSavedOrder() {
    descending = appLocalStorage.getPageOrder(pageRoute: pageRoute);
  }

  Future removeFav(Quote quote) async {
    final index = quotes.indexOf(quote);

    setState(() {
      // optimistic
      quotes.removeAt(index);
    });

    try {
      final result = await removeFromFavourites(quote: quote);

      if (!result) {
        setState(() {
          quotes.insert(index, quote);
        });
      }

      userState.updateFavDate();
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        quotes.insert(index, quote);
      });

      showSnack(
        context: context,
        message:
            "There was an issue while removing the quote from your favourites.",
        type: SnackType.error,
      );
    }
  }
}
