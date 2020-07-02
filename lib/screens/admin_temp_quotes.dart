import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/quotes.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/order_lang_button.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/quote_card.dart';
import 'package:memorare/components/web/sliver_app_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';

class AdminTempQuotes extends StatefulWidget {
  @override
  AdminTempQuotesState createState() => AdminTempQuotesState();
}

class AdminTempQuotesState extends State<AdminTempQuotes> {
  bool hasNext        = true;
  bool hasErrors      = false;
  bool isLoading      = false;
  bool isLoadingMore  = false;
  String lang         = 'en';
  int limit           = 30;
  bool descending     = true;
  final pageRoute     = AdminTempQuotesRoute;

  List<TempQuote> tempQuotes = [];
  ScrollController scrollController = ScrollController();

  var lastDoc;

  @override
  initState() {
    super.initState();
    getSavedLangAndOrder();
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
    return SliverAppHeader(
      title: 'All in validation',
      onScrollToTop: () {
        if (tempQuotes.length == 0) {
          return;
        }

        scrollController.animateTo(
          0,
          duration: Duration(seconds: 2),
          curve: Curves.easeOutQuint
        );
      },
      rightButton: OrderLangButton(
        descending: descending,
        lang: lang,
        onLangChanged: (String newLang) {
          appLocalStorage.setPageLang(
            lang: newLang,
            pageRoute: pageRoute,
          );

          setState(() {
            lang = newLang;
          });

          fetch();
        },
        onOrderChanged: (bool order) {
          appLocalStorage.setPageOrder(
            descending: order,
            pageRoute: pageRoute,
          );

          setState(() {
            descending = order;
          });

          fetch();
        },
      ),
    );
  }

  Widget bodyListContent() {
    if (isLoading) {
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

    if (!isLoading && hasErrors) {
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

    if (tempQuotes.length == 0) {
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
          ]
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constrains) {
        if (constrains.crossAxisExtent < 600.0) {
          return sliverQuotesList();
        }

        return sliverGrid();
      },
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
          final color = Color(topicColor.decimal);

          return QuoteCard(
            onTap: () => editAction(tempQuote),
            onLongPress: () => validateAction(tempQuote),
            title: tempQuote.name,
            popupMenuButton: popupMenuButton(
              color: color,
              tempQuote: tempQuote,
            ),
          );
        },
        childCount: tempQuotes.length,
      ),
    );
  }

  Widget popupMenuButton({Color color, TempQuote tempQuote}) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        color: color != null
            ? color
            : Colors.primaries,
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
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<String>>[
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

  Widget sliverQuotesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tempQuote = tempQuotes.elementAt(index);
          final topicColor = appTopicsColors.find(tempQuote.topics.first);
          final color = Color(topicColor.decimal);

          return Card(
            elevation: 0.0,
            child: InkWell(
              onTap: () {
                editAction(tempQuote);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 40.0,
                    ),
                    child: Text(
                      tempQuote.name,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),

                  Center(
                    child: popupMenuButton(
                      color: color,
                      tempQuote: tempQuote,
                    ),
                  ),

                  Padding(padding: const EdgeInsets.only(bottom: 20.0),),
                ],
              ),
            ),
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
        FluroRouter.router.navigateTo(context, SigninRoute, replace: true,);
        return;
      }

    } catch (error) {
      FluroRouter.router.navigateTo(context, SigninRoute, replace: true,);
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

    if (isOk) { return; }

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
    FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
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
    if (lastDoc == null) { return; }

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

  void getSavedLangAndOrder() {
    lang = appLocalStorage.getPageLang(pageRoute: pageRoute);
    descending = appLocalStorage.getPageOrder(pageRoute: pageRoute);
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

    if (isOk) { return; }

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
