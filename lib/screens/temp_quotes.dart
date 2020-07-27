import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/quote_card.dart';
import 'package:memorare/components/simple_appbar.dart';
import 'package:memorare/components/temp_quote_row.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import'package:memorare/components/loading_animation.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';

class MyTempQuotes extends StatefulWidget {
  @override
  MyTempQuotesState createState() => MyTempQuotesState();
}

class MyTempQuotesState extends State<MyTempQuotes> {
  bool hasNext        = true;
  bool hasErrors      = false;
  bool isLoading      = false;
  bool isLoadingMore  = false;
  String lang         = 'all';
  int limit           = 30;
  int order           = -1;
  bool descending     = false;
  final pageRoute     = TempQuotesRoute;
  bool isFabVisible   = false;

  List<TempQuote> tempQuotes = [];
  ScrollController scrollController = ScrollController();

  var lastDoc;

  @override
  initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible ?
        FloatingActionButton(
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
        ) : null,
      body: body(),
    );
  }

  Widget body() {
    return RefreshIndicator(
      onRefresh: () async {
        await fetch();
        return null;
      },
      child: NotificationListener<ScrollNotification>(
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
          if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
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
            bodyListContent(),
          ],
        ),
      )
    );
  }

  Widget appBar() {
    return SimpleAppBar(
      textTitle: 'In Validation',
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
                      color: !descending ?
                        Colors.white :
                        stateColors.foreground,
                    ),
                  ),
                  selected: !descending,
                  selectedColor: stateColors.primary,
                  onSelected: (selected) {
                    if (!descending) { return; }

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
                      color: descending ?
                        Colors.white :
                        stateColors.foreground,
                    ),
                  ),
                  selected: descending,
                  selectedColor: stateColors.primary,
                  onSelected: (selected) {
                    if (descending) { return; }

                    descending = true;
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
                delay: 3.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Container(
                    height: 25,
                    width: 2.0,
                    color: stateColors.foreground,
                  ),
                ),
              ),

              FadeInY(
                beginY: 10.0,
                delay: 3.5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: DropdownButton<String>(
                    elevation: 2,
                    value: lang,
                    isDense: true,
                    underline: Container(
                      height: 0,
                      color: Colors.deepPurpleAccent,
                    ),
                    icon: Icon(Icons.keyboard_arrow_down),
                    style: TextStyle(
                      color: stateColors.foreground.withOpacity(0.6),
                      fontFamily: 'Comfortaa',
                      fontSize: 20.0,
                    ),
                    onChanged: (String newLang) {
                      lang = newLang;
                      fetch();
                    },
                    items: ['all', 'en', 'fr'].map((String value) {
                      return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value.toUpperCase(),
                          ));
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget bodyListContent() {
    if (isLoading) {
      return loadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (tempQuotes.length == 0) {
      return emptyView();
    }

    return contentView();
  }

  Widget contentView() {
    return SliverLayoutBuilder(
      builder: (context, constrains) {
        return sliverList();

        // if (constrains.crossAxisExtent < 600.0) {
        //   return SliverPadding(
        //     padding: const EdgeInsets.only(
        //       top: 80.0,
        //     ),
        //     sliver: sliverList(),
        //   );
        // }

        // return SliverPadding(
        //   padding: const EdgeInsets.only(
        //     top: 80.0,
        //     left: 10.0,
        //     right: 10.0,
        //     bottom: 200.0,
        //   ),
        //   sliver: sliverGrid(),
        // );
      },
    );
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
        ]
      ),
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

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: LoadingAnimation(),
          ),
        ]
      ),
    );
  }

  Widget sliverGrid() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final tempQuote = tempQuotes.elementAt(index);
          final topicColor = appTopicsColors.find(tempQuote.topics.first);

          return QuoteCard(
            onTap: () => editTempQuote(tempQuote),
            title: tempQuote.name,
            popupMenuButton: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz,
                color: topicColor != null ?
                  Color(topicColor.decimal) : Colors.primaries,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  deleteAction(tempQuote);
                  return;
                }

                if (value == 'edit') {
                  editTempQuote(tempQuote);
                  return;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_forever),
                    title: Text('Delete'),
                  )
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  )
                ),
              ],
            ),
          );
        },
        childCount: tempQuotes.length,
      ),
    );
  }

  Widget sliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tempQuote = tempQuotes.elementAt(index);

          return TempQuoteRow(
            quote: tempQuote,
            isDraft: false,
            onTap: () => editTempQuote(tempQuote),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  )),
              PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_sweep),
                    title: Text('Delete'),
                  )),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                editTempQuote(tempQuote);
                return;
              }

              if (value == 'delete') {
                deleteAction(tempQuote);
                return;
              }
            },
          );
        },
        childCount: tempQuotes.length,
      ),
    );
  }

  void deleteAction(TempQuote tempQuote) async {
    int index = tempQuotes.indexOf(tempQuote);

    setState(() {
      tempQuotes.removeAt(index);
    });

    final success = await deleteTempQuote(
      context: context,
      tempQuote: tempQuote,
    );

    if (!success) {
      tempQuotes.insert(index, tempQuote);

      showSnack(
        context: context,
        message: "Couldn't delete the temporary quote.",
        type: SnackType.error,
      );
    }
  }

  void editTempQuote(TempQuote tempQuote) async {
    AddQuoteInputs.populateWithTempQuote(tempQuote);
    FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
    });

    tempQuotes.clear();

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        throw Error();
      }

      QuerySnapshot snapshot;

      if (lang == 'all') {
        snapshot = await Firestore.instance
          .collection('tempquotes')
          .where('user.id', isEqualTo: userAuth.uid)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .getDocuments();

      } else {
        snapshot = await Firestore.instance
          .collection('tempquotes')
          .where('user.id', isEqualTo: userAuth.uid)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .getDocuments();
      }

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasErrors = false;
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
        hasErrors = false;
        hasNext = snapshot.documents.length == limit;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
        hasErrors = true;
      });

      if (!userState.isUserConnected) {
        FluroRouter.router.navigateTo(context, SigninRoute);
      }
    }
  }

  void fetchMore() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        throw Error();
      }

      QuerySnapshot snapshot;

      if (lang == 'all') {
        snapshot = await Firestore.instance
          .collection('tempquotes')
          .startAfterDocument(lastDoc)
          .where('user.id', isEqualTo: userAuth.uid)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .getDocuments();

      } else {
        snapshot = await Firestore.instance
          .collection('tempquotes')
          .startAfterDocument(lastDoc)
          .where('user.id', isEqualTo: userAuth.uid)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .getDocuments();
      }

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
        hasNext = snapshot.documents.length == limit;
        isLoadingMore = false;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }
}
