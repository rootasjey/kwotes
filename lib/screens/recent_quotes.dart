import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/actions/quotes.dart';
import 'package:figstyle/actions/quotidians.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/sliver_loading_view.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/utils/app_localstorage.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class RecentQuotes extends StatefulWidget {
  final bool showNavBackIcon;

  RecentQuotes({this.showNavBackIcon = true});

  @override
  RecentQuotesState createState() => RecentQuotesState();
}

class RecentQuotesState extends State<RecentQuotes> {
  bool canManage = false;
  bool descending = true;
  bool hasNext = true;
  bool hasErrors = false;
  bool isConnected = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  final pageRoute = QuotesRoute;

  final limit = 30;
  List<Quote> quotes = [];
  String lang = 'en';

  var itemsLayout = ItemsLayout.list;
  var lastDoc;
  var scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    initProps();
    fetchPermissions();
    fetch();
  }

  void initProps() {
    lang = appLocalStorage.getPageLang(pageRoute: pageRoute);
    descending = appLocalStorage.getPageOrder(pageRoute: pageRoute);
    itemsLayout = appLocalStorage.getItemsStyle(pageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: () async {
            await fetch();
            return null;
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotif) {
              if (scrollNotif.metrics.pixels <
                  scrollNotif.metrics.maxScrollExtent) {
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
                body(),
              ],
            ),
          )),
    );
  }

  Widget appBar() {
    return PageAppBar(
      textTitle: 'Recent',
      onTitlePressed: () {
        scrollController.animateTo(
          0,
          duration: 250.milliseconds,
          curve: Curves.easeIn,
        );
      },
      descending: descending,
      onDescendingChanged: (newDescending) {
        if (descending == newDescending) {
          return;
        }

        descending = newDescending;
        fetch();

        appLocalStorage.setPageOrder(
          descending: newDescending,
          pageRoute: pageRoute,
        );
      },
      lang: lang,
      onLangChanged: (String newLang) {
        lang = newLang;
        fetch();
      },
      itemsLayout: itemsLayout,
      onItemsLayoutSelected: (selectedLayout) {
        if (selectedLayout == itemsLayout) {
          return;
        }

        setState(() {
          itemsLayout = selectedLayout;
        });

        appLocalStorage.saveItemsStyle(
          pageRoute: pageRoute,
          style: selectedLayout,
        );
      },
    );
  }

  Widget body() {
    if (isLoading) {
      return SliverLoadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (quotes.length == 0) {
      return emptyView();
    }

    if (itemsLayout == ItemsLayout.list) {
      return listView();
    }

    return gridView();
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 2.0,
          beginY: 50.0,
          child: EmptyContent(
            icon: Opacity(
              opacity: .8,
              child: Icon(
                Icons.sentiment_neutral,
                size: 120.0,
                color: Color(0xFFFF005C),
              ),
            ),
            title: "There's no recent quotes",
            subtitle: "Maybe your this language has been added recently",
            onRefresh: () => fetch(),
          ),
        ),
      ]),
    );
  }

  Widget errorView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: ErrorContainer(
            onRefresh: () => fetch(),
          ),
        ),
      ]),
    );
  }

  Widget gridView() {
    return Observer(builder: (context) {
      final isConnected = userState.isUserConnected;

      return SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300.0,
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final quote = quotes.elementAt(index);

              return QuoteRowWithActions(
                quote: quote,
                isConnected: isConnected,
                componentType: ItemComponentType.card,
                onBeforeDeletePubQuote: () {
                  setState(() {
                    quotes.removeAt(index);
                  });
                },
                onAfterDeletePubQuote: (bool success) {
                  if (!success) {
                    quotes.insert(index, quote);

                    showSnack(
                      context: context,
                      message: "Couldn't delete the temporary quote.",
                      type: SnackType.error,
                    );
                  }
                },
              );
            },
            childCount: quotes.length,
          ),
        ),
      );
    });
  }

  Widget listView() {
    final width = MediaQuery.of(context).size.width;
    double horPadding = width < 700.00 ? 20.0 : 70.0;

    if (width < 390.0) {
      horPadding = 0.0;
    }

    return Observer(builder: (context) {
      final isConnected = userState.isUserConnected;

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final quote = quotes.elementAt(index);

            return QuoteRowWithActions(
              quote: quote,
              isConnected: isConnected,
              color: stateColors.appBackground,
              padding: EdgeInsets.symmetric(
                horizontal: horPadding,
              ),
              quotePageType: QuotePageType.published,
            );
          },
          childCount: quotes.length,
        ),
      );
    });
  }

  void addQuotidianAction(Quote quote) async {
    final success = await addToQuotidians(
      quote: quote,
      lang: lang,
    );

    if (success) {
      showSnack(
        context: context,
        message: 'Quote successfully added.',
        type: SnackType.success,
      );
      return;
    }

    showSnack(
      context: context,
      message: 'Sorry, an error occurred while adding the quotes to quotidian.',
      type: SnackType.error,
    );
  }

  void fetchPermissions() async {
    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        return;
      }

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .get();

      if (user == null) {
        return;
      }

      setState(() {
        isConnected = true;
        canManage = user.data()['rights']['user:managequotidian'];
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void deleteAction(Quote quote) async {
    int index = quotes.indexOf(quote);

    setState(() {
      quotes.removeAt(index);
    });

    final success = await deleteQuote(quote: quote);

    if (!success) {
      quotes.insert(index, quote);

      showSnack(
        context: context,
        message: "Couldn't delete the temporary quote.",
        type: SnackType.error,
      );
    }
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      quotes.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
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
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMore() async {
    if (lastDoc == null) {
      return;
    }
    isLoadingMore = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
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
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void showDeleteDialog(Quote quote) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'Confirm deletion?',
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(3.0),
                      ),
                    ),
                    color: stateColors.softBackground,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 15.0,
                      ),
                      child: Text(
                        'NO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 15.0)),
                  RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteAction(quote);
                    },
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(3.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 15.0,
                      ),
                      child: Text(
                        'YES',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
