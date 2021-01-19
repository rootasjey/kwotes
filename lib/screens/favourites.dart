import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/favourites.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

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

  DocumentSnapshot lastDoc;

  final int limit = 30;

  ItemsLayout itemsLayout = ItemsLayout.list;

  List<Quote> quotes = [];

  final ScrollController scrollController = ScrollController();
  final String pageRoute = RouteNames.FavouritesRoute;

  @override
  initState() {
    super.initState();
    initProps();
    fetch();
  }

  void initProps() {
    descending = appStorage.getPageOrder(pageRoute: pageRoute);
    itemsLayout = appStorage.getItemsStyle(pageRoute);
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
      body: OrientationBuilder(
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
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (_) => CustomScrollView(
                    controller: scrollController,
                    slivers: <Widget>[
                      SliverPadding(padding: const EdgeInsets.only(top: 40.0)),
                      appBar(),
                      body(screenWidth: screenWidth),
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 200.0),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;
    double titleLeftPadding = 70.0;
    double bottomContentLeftPadding = 94.0;

    if (width < Constants.maxMobileWidth) {
      titleLeftPadding = 0.0;
      bottomContentLeftPadding = 24.0;
    }

    return PageAppBar(
      textTitle: 'Favourites',
      textSubTitle: 'Quotes you loved the most',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
      ),
      bottomPadding: EdgeInsets.only(
        left: bottomContentLeftPadding,
        bottom: 10.0,
      ),
      showNavBackIcon: true,
      onTitlePressed: () {
        scrollController.animateTo(
          0,
          duration: 250.milliseconds,
          curve: Curves.easeIn,
        );
      },
      onIconPressed: () => Navigator.of(context).pop(),
      descending: descending,
      onDescendingChanged: (newDescending) {
        if (descending == newDescending) {
          return;
        }

        descending = newDescending;
        fetch();

        appStorage.setPageOrder(
          descending: newDescending,
          pageRoute: pageRoute,
        );
      },
      itemsLayout: itemsLayout,
      onItemsLayoutSelected: (selectedLayout) {
        if (selectedLayout == itemsLayout) {
          return;
        }

        setState(() {
          itemsLayout = selectedLayout;
        });

        appStorage.saveItemsStyle(
          pageRoute: pageRoute,
          style: selectedLayout,
        );
      },
    );
  }

  Widget body({double screenWidth}) {
    if (isLoading) {
      return loadingView();
    }

    if (quotes.length == 0) {
      return emptyView();
    }

    final Widget sliver =
        itemsLayout == ItemsLayout.list ? listView() : gridView();

    return SliverPadding(
      padding: const EdgeInsets.only(top: 24.0),
      sliver: sliver,
    );
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 100.milliseconds,
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

  Widget gridView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final quote = quotes.elementAt(index);

            return QuoteRowWithActions(
              quote: quote,
              quoteId: quote.quoteId,
              componentType: ItemComponentType.card,
              quotePageType: QuotePageType.favourites,
              padding: const EdgeInsets.all(20.0),
              elevation: Constants.cardElevation,
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

                stateUser.updateFavDate();
              },
            );
          },
          childCount: quotes.length,
        ),
      ),
    );
  }

  Widget listView() {
    double horPadding = 70.0;
    bool useSwipeActions = false;

    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      horPadding = 0.0;
      useSwipeActions = true;
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final quote = quotes.elementAt(index);

          return QuoteRowWithActions(
            quote: quote,
            quoteId: quote.quoteId,
            color: stateColors.appBackground,
            isConnected: true,
            key: ObjectKey(index),
            useSwipeActions: useSwipeActions,
            quotePageType: QuotePageType.favourites,
            padding: EdgeInsets.symmetric(
              horizontal: horPadding,
            ),
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

              stateUser.updateFavDate();
            },
          );
        },
        childCount: quotes.length,
      ),
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

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    quotes.clear();

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        setState(() {
          isLoading = false;
        });

        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('favourites')
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
          hasNext = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        isLoading = false;
        hasNext = limit == snapshot.docs.length;
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
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('favourites')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        isLoadingMore = false;
        hasNext = limit == snapshot.docs.length;
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

      stateUser.updateFavDate();
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
