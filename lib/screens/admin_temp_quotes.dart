import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/quotes.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/simple_appbar.dart';
import 'package:memorare/components/sliver_loading_view.dart';
import 'package:memorare/components/temp_quote_row.dart';
import 'package:memorare/components/temp_quote_row_with_actions.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/enums.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';

import 'add_quote/steps.dart';

class AdminTempQuotes extends StatefulWidget {
  @override
  AdminTempQuotesState createState() => AdminTempQuotesState();
}

class AdminTempQuotesState extends State<AdminTempQuotes> {
  bool hasNext = true;
  bool hasErrors = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  String lang = 'en';
  var lastDoc;
  int limit = 30;
  bool descending = true;
  var itemsStyle = ItemsLayout.list;
  final pageRoute = AdminTempQuotesRoute;

  var scrollController = ScrollController();
  var tempQuotes = List<TempQuote>();

  @override
  initState() {
    super.initState();
    getSavedProps();
    checkAuth();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              bodyListContent(),
            ],
          ),
        ));
  }

  Widget appBar() {
    return SimpleAppBar(
      textTitle: 'All In Validation',
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
                    color: stateColors.foreground.withOpacity(0.5),
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

                      appLocalStorage.setPageLang(
                        lang: lang,
                        pageRoute: pageRoute,
                      );
                    },
                    items: ['en', 'fr'].map((String value) {
                      return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value.toUpperCase(),
                          ));
                    }).toList(),
                  ),
                ),
              ),
              FadeInY(
                beginY: 10.0,
                delay: 3.2,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: Container(
                    height: 25,
                    width: 2.0,
                    color: stateColors.foreground.withOpacity(0.5),
                  ),
                ),
              ),
              FadeInY(
                beginY: 10.0,
                delay: 3.5,
                child: IconButton(
                  onPressed: () {
                    if (itemsStyle == ItemsLayout.list) {
                      return;
                    }

                    setState(() {
                      itemsStyle = ItemsLayout.list;
                    });

                    appLocalStorage.saveItemsStyle(
                      pageRoute: pageRoute,
                      style: ItemsLayout.list,
                    );
                  },
                  icon: Icon(Icons.list),
                  color: itemsStyle == ItemsLayout.list
                      ? stateColors.primary
                      : stateColors.foreground.withOpacity(0.5),
                ),
              ),
              FadeInY(
                beginY: 10.0,
                delay: 3.5,
                child: IconButton(
                  onPressed: () {
                    if (itemsStyle == ItemsLayout.grid) {
                      return;
                    }

                    setState(() {
                      itemsStyle = ItemsLayout.grid;
                    });

                    appLocalStorage.saveItemsStyle(
                      pageRoute: pageRoute,
                      style: ItemsLayout.grid,
                    );
                  },
                  icon: Icon(Icons.grid_on),
                  color: itemsStyle == ItemsLayout.grid
                      ? stateColors.primary
                      : stateColors.foreground.withOpacity(0.5),
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
      return SliverLoadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (tempQuotes.length == 0) {
      return emptyView();
    }

    if (itemsStyle == ItemsLayout.grid) {
      return sliverGrid();
    }

    return sliverList();
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

  Widget sliverGrid() {
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
              onTap: () => editAction(tempQuote),
              tempQuote: tempQuote,
            );
          },
          childCount: tempQuotes.length,
        ),
      ),
    );
  }

  Widget popupMenuButton({Color color, TempQuote tempQuote}) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        color: color != null ? color : Colors.primaries,
      ),
      onSelected: (value) {
        if (value == 'delete') {
          deleteAction(tempQuote);
          return;
        }

        if (value == 'edit') {
          editAction(tempQuote);
          return;
        }

        if (value == 'validate') {
          validateAction(tempQuote);
          return;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_forever),
              title: Text('Delete'),
            )),
        PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            )),
        PopupMenuItem(
            value: 'validate',
            child: ListTile(
              leading: Icon(Icons.check),
              title: Text('Validate'),
            )),
      ],
    );
  }

  Widget sliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tempQuote = tempQuotes.elementAt(index);

          return TempQuoteRow(
            tempQuote: tempQuote,
            onTap: () => editAction(tempQuote),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_forever),
                    title: Text('Delete'),
                  )),
              PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  )),
              PopupMenuItem(
                  value: 'validate',
                  child: ListTile(
                    leading: Icon(Icons.check),
                    title: Text('Validate'),
                  )),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                deleteAction(tempQuote);
                return;
              }

              if (value == 'edit') {
                editAction(tempQuote);
                return;
              }

              if (value == 'validate') {
                validateAction(tempQuote);
                return;
              }
            },
          );
        },
        childCount: tempQuotes.length,
      ),
    );
  }

  void checkAuth() async {
    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => Signin()));
      }
    } catch (error) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => Signin()));
    }
  }

  void deleteAction(TempQuote tempQuote) async {
    int index = tempQuotes.indexOf(tempQuote);

    setState(() {
      tempQuotes.remove(tempQuote);
    });

    final isOk = await deleteTempQuoteAdmin(
      context: context,
      tempQuote: tempQuote,
    );

    if (isOk) {
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
  }

  void editAction(TempQuote tempQuote) async {
    AddQuoteInputs.navigatedFromPath = 'admintempquotes';
    AddQuoteInputs.populateWithTempQuote(tempQuote);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AddQuoteSteps()));
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

  void getSavedProps() {
    lang = appLocalStorage.getPageLang(pageRoute: pageRoute);
    descending = appLocalStorage.getPageOrder(pageRoute: pageRoute);
    itemsStyle = appLocalStorage.getItemsStyle(pageRoute);
  }

  void validateAction(TempQuote tempQuote) async {
    int index = tempQuotes.indexOf(tempQuote);

    setState(() {
      tempQuotes.remove(tempQuote);
    });

    final userAuth = await userState.userAuth;

    final isOk = await validateTempQuote(
      tempQuote: tempQuote,
      uid: userAuth.uid,
    );

    if (isOk) {
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
  }
}
