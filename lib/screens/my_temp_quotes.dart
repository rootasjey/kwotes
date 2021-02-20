import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/sliver_edge_padding.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/temp_quote_row_with_actions.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/temp_quote.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class MyTempQuotes extends StatefulWidget {
  @override
  MyTempQuotesState createState() => MyTempQuotesState();
}

class MyTempQuotesState extends State<MyTempQuotes> {
  bool descending = false;
  bool hasNext = true;
  bool hasErrors = false;
  bool isFabVisible = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  DocumentSnapshot lastDoc;

  ItemsLayout itemsLayout = ItemsLayout.list;

  int limit = 30;
  int order = -1;

  String lang = 'en';
  final String pageRoute = RouteNames.TempQuotesRoute;
  final _pageScrollController = ScrollController();

  List<TempQuote> tempQuotes = [];

  @override
  initState() {
    super.initState();
    initProps();
    fetch();
  }

  void initProps() {
    lang = appStorage.getPageLang(pageRoute: pageRoute);
    descending = appStorage.getPageOrder(pageRoute: pageRoute);
    itemsLayout = appStorage.getItemsStyle(pageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                _pageScrollController.animateTo(
                  0.0,
                  duration: 500.milliseconds,
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: stateColors.primary,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: RefreshIndicator(
          onRefresh: () async {
            await fetch();
            return null;
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotif) {
              // FAB visibility
              if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
                setState(() => isFabVisible = false);
              } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
                setState(() => isFabVisible = true);
              }

              // Load more scenario
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
              controller: _pageScrollController,
              slivers: <Widget>[
                SliverEdgePadding(),
                appBar(),
                body(),
              ],
            ),
          )),
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
      textTitle: 'In validation',
      textSubTitle: 'Your quotes waiting to be validated',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
      ),
      bottomPadding: EdgeInsets.only(
        left: bottomContentLeftPadding,
        bottom: 10.0,
      ),
      onTitlePressed: () {
        _pageScrollController.animateTo(
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

        appStorage.setPageOrder(
          descending: newDescending,
          pageRoute: pageRoute,
        );
      },
      lang: lang,
      onLangChanged: (String newLang) {
        lang = newLang;
        appStorage.setPageLang(lang: lang, pageRoute: pageRoute);
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

        appStorage.saveItemsStyle(
          pageRoute: pageRoute,
          style: selectedLayout,
        );
      },
    );
  }

  Widget body() {
    if (isLoading) {
      return loadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (tempQuotes.length == 0) {
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
          child: EmptyContent(
            icon: Opacity(
              opacity: .8,
              child: Icon(
                Icons.timelapse,
                size: 120.0,
                color: Color(0xFFFF005C),
              ),
            ),
            title: "You've no quote in validation at this moment",
            subtitle: 'They will appear after you propose a new quote',
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
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final tempQuote = tempQuotes.elementAt(index);

            return TempQuoteRowWithActions(
              componentType: ItemComponentType.card,
              tempQuote: tempQuote,
              elevation: Constants.cardElevation,
              onBeforeDelete: () {
                setState(() {
                  tempQuotes.removeAt(index);
                });
              },
              onAfterDelete: (success) {
                if (success) {
                  return;
                }

                setState(() {
                  tempQuotes.insert(index, tempQuote);
                });

                Snack.e(
                  context: context,
                  message: "Couldn't delete the temporary quote",
                );
              },
              onBeforeValidate: () {
                setState(() {
                  tempQuotes.removeAt(index);
                });
              },
              onAfterValidate: (success) {
                if (success) {
                  return;
                }

                setState(() {
                  tempQuotes.insert(index, tempQuote);
                });

                Snack.e(
                  context: context,
                  message: "Couldn't validate your temporary quote.",
                );
              },
              onNavBack: () {
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  fetch();
                });
              },
            );
          },
          childCount: tempQuotes.length,
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
        (context, index) {
          final tempQuote = tempQuotes.elementAt(index);

          return TempQuoteRowWithActions(
            tempQuote: tempQuote,
            isDraft: false,
            padding: EdgeInsets.symmetric(horizontal: horPadding),
            key: ObjectKey(index),
            useSwipeActions: useSwipeActions,
            onBeforeDelete: () {
              setState(() {
                tempQuotes.removeAt(index);
              });
            },
            onAfterDelete: (success) {
              if (success) {
                return;
              }

              setState(() {
                tempQuotes.insert(index, tempQuote);
              });

              Snack.e(
                context: context,
                message: "Couldn't delete the temporary quote",
              );
            },
            onBeforeValidate: () {
              setState(() {
                tempQuotes.removeAt(index);
              });
            },
            onAfterValidate: (success) {
              if (success) {
                return;
              }

              setState(() {
                tempQuotes.insert(index, tempQuote);
              });

              Snack.e(
                context: context,
                message: "Couldn't validate your temporary quote.",
              );
            },
            onNavBack: () {
              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                fetch();
              });
            },
          );
        },
        childCount: tempQuotes.length,
      ),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 200.0),
          child: LoadingAnimation(),
        ),
      ]),
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      tempQuotes.clear();
    });

    try {
      QuerySnapshot snapshot;

      if (lang == 'all') {
        snapshot = await FirebaseFirestore.instance
            .collection('tempquotes')
            .where('user.id', isEqualTo: stateUser.userAuth.uid)
            .orderBy('createdAt', descending: descending)
            .limit(limit)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('tempquotes')
            .where('user.id', isEqualTo: stateUser.userAuth.uid)
            .where('lang', isEqualTo: lang)
            .orderBy('createdAt', descending: descending)
            .limit(limit)
            .get();
      }

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasErrors = false;
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = TempQuote.fromJSON(data);
        tempQuotes.add(quote);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        isLoading = false;
        hasErrors = false;
        hasNext = snapshot.docs.length == limit;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
        hasErrors = true;
      });
    }
  }

  void fetchMore() async {
    if (lastDoc == null) {
      return;
    }

    setState(() => isLoadingMore = true);

    try {
      QuerySnapshot snapshot;

      if (lang == 'all') {
        snapshot = await FirebaseFirestore.instance
            .collection('tempquotes')
            .startAfterDocument(lastDoc)
            .where('user.id', isEqualTo: stateUser.userAuth.uid)
            .orderBy('createdAt', descending: descending)
            .limit(limit)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('tempquotes')
            .startAfterDocument(lastDoc)
            .where('user.id', isEqualTo: stateUser.userAuth.uid)
            .where('lang', isEqualTo: lang)
            .orderBy('createdAt', descending: descending)
            .limit(limit)
            .get();
      }

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

        final quote = TempQuote.fromJSON(data);
        tempQuotes.insert(tempQuotes.length - 1, quote);
      });

      setState(() {
        hasNext = snapshot.docs.length == limit;
        isLoadingMore = false;
      });
    } catch (error) {
      debugPrint(error.toString());
      setState(() => isLoadingMore = false);
    }
  }
}
