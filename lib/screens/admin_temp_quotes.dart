import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/page_app_bar.dart';
import 'package:memorare/components/sliver_loading_view.dart';
import 'package:memorare/components/temp_quote_row_with_actions.dart';
import 'package:memorare/components/empty_content.dart';
import 'package:memorare/components/fade_in_y.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/types/enums.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/auth.dart';
import 'package:memorare/utils/snack.dart';
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

  String pageRoute = AdminTempQuotesRoute;
  String lang = 'en';

  @override
  initState() {
    super.initState();
    initProps();
    checkConnectedOrNavSignin();
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
      textTitle: 'All in validation',
      textSubTitle: 'Quotes in validation from all users',
      expandedHeight: 170.0,
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

        appLocalStorage.setPageLang(
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

    if (tempQuotes.length == 0) {
      return emptyView();
    }

    if (itemsLayout == ItemsLayout.grid) {
      return gridView();
    }

    return listView();
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
                fetch();
              },
            );
          },
          childCount: tempQuotes.length,
        ),
      ),
    );
  }

  Widget listView() {
    final horPadding = MediaQuery.of(context).size.width < 700.00 ? 20.0 : 70.0;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tempQuote = tempQuotes.elementAt(index);

          return TempQuoteRowWithActions(
            tempQuote: tempQuote,
            canManage: true,
            padding: EdgeInsets.symmetric(
              horizontal: horPadding,
            ),
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
              fetch();
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
      final snapshot = await Firestore.instance
          .collection('tempquotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(30)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = TempQuote.fromJSON(data);
        tempQuotes.add(quote);
      });

      lastDoc = snapshot.documents.last;

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
      final snapshot = await Firestore.instance
          .collection('tempquotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(30)
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
