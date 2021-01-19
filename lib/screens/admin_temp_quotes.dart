import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/sliver_loading_view.dart';
import 'package:figstyle/components/temp_quote_row_with_actions.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/temp_quote.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/auth.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class AdminTempQuotes extends StatefulWidget {
  @override
  AdminTempQuotesState createState() => AdminTempQuotesState();
}

class AdminTempQuotesState extends State<AdminTempQuotes> {
  bool descending = true;
  bool hasNext = true;
  bool hasErrors = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  int limit = 30;

  DocumentSnapshot lastDoc;
  ItemsLayout itemsLayout = ItemsLayout.list;
  List<TempQuote> tempQuotes = [];

  ScrollController scrollController = ScrollController();

  String pageRoute = RouteNames.AdminTempQuotesRoute;
  String lang = 'en';

  @override
  initState() {
    super.initState();
    initProps();
    checkConnectedOrNavSignin();
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
                SliverPadding(padding: const EdgeInsets.only(top: 40.0)),
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
      textTitle: 'All in validation',
      textSubTitle: 'Quotes in validation from all users',
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

        appStorage.setPageLang(
          pageRoute: pageRoute,
          lang: lang,
        );

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
      return SliverLoadingView();
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
          delay: 200.milliseconds,
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
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: 100.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final tempQuote = tempQuotes.elementAt(index);

            return TempQuoteRowWithActions(
              componentType: ItemComponentType.card,
              canManage: true,
              tempQuote: tempQuote,
              padding: const EdgeInsets.all(20.0),
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

                showSnack(
                  context: context,
                  message: "Couldn't delete the temporary quote",
                  type: SnackType.error,
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

                showSnack(
                  context: context,
                  message: "Couldn't validate your temporary quote.",
                  type: SnackType.error,
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
    bool showPopupMenuButton = true;

    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      horPadding = 0.0;
      showPopupMenuButton = false;
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tempQuote = tempQuotes.elementAt(index);

          return TempQuoteRowWithActions(
            tempQuote: tempQuote,
            canManage: true,
            padding: EdgeInsets.symmetric(horizontal: horPadding),
            key: ObjectKey(index),
            showPopupMenuButton: showPopupMenuButton,
            useSwipeActions: true,
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

              showSnack(
                context: context,
                message: "Couldn't delete the temporary quote",
                type: SnackType.error,
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

              showSnack(
                context: context,
                message: "Couldn't validate your temporary quote.",
                type: SnackType.error,
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

  Future fetch() async {
    setState(() {
      isLoading = true;
      tempQuotes.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tempquotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(30)
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

        final quote = TempQuote.fromJSON(data);
        tempQuotes.add(quote);
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

    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tempquotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(30)
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

        final quote = TempQuote.fromJSON(data);
        tempQuotes.insert(tempQuotes.length - 1, quote);
      });

      setState(() {
        isLoadingMore = false;
      });
    } catch (error) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }
}
