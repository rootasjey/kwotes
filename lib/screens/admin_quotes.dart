import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/quotes.dart';
import 'package:memorare/actions/quotidians.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/order_lang_button.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';

class AdminQuotes extends StatefulWidget {
  @override
  AdminQuotesState createState() => AdminQuotesState();
}

class AdminQuotesState extends State<AdminQuotes> {
  bool canManage      = false;
  bool hasNext        = true;
  bool hasErrors      = false;
  bool isLoading      = false;
  bool isLoadingMore  = false;
  String lang         = 'en';
  int limit           = 30;
  bool descending     = true;

  List<Quote> quotes = [];
  ScrollController scrollController = ScrollController();

  var lastDoc;

  @override
  initState() {
    super.initState();
    getSavedLangAndOrder();
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
    return Observer(
      builder: (_) {
        return SliverAppBar(
          floating: true,
          snap: true,
          expandedHeight: 120.0,
          backgroundColor: stateColors.softBackground,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: <Widget>[
              FadeInY(
                delay: 1.0,
                beginY: 50.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: FlatButton(
                    onPressed: () {
                      if (quotes.length == 0) { return; }

                      scrollController.animateTo(
                        0,
                        duration: Duration(seconds: 2),
                        curve: Curves.easeOutQuint
                      );
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 60.0,
                      child: Text(
                        'All published',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 20.0,
                top: 50.0,
                child: OrderLangButton(
                  descending: descending,
                  lang: lang,
                  onLangChanged: (String newLang) {
                    appLocalStorage.setPageLang(
                      lang: newLang,
                      pageRoute: QuotesRoute,
                    );

                    setState(() {
                      lang = newLang;
                    });

                    fetch();
                  },
                  onOrderChanged: (bool order) {
                    appLocalStorage.setPageOrder(
                      descending: order,
                      pageRoute: QuotesRoute,
                    );

                    setState(() {
                      descending = order;
                    });

                    fetch();
                  },
                ),
              ),

              Positioned(
                left: 20.0,
                top: 50.0,
                child: IconButton(
                  onPressed: () {
                    FluroRouter.router.pop(context);
                  },
                  tooltip: 'Back',
                  icon: Icon(Icons.arrow_back),
                ),
              ),
            ],
          ),
        );
      },
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

    if (quotes.length == 0) {
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

    return sliverQuotesList();
  }

  Widget sliverQuotesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final quote = quotes.elementAt(index);
          final topicColor = appTopicsColors.find(quote.topics.first);

          return FadeInY(
            delay: index * 1.0,
            beginY: 50.0,
            child: InkWell(
              onTap: () => FluroRouter.router.navigateTo(context, QuotePageRoute.replaceFirst(':id', quote.id)),
              onLongPress: () => showQuoteSheet(quote: quote),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(top: 20.0),),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      quote.name,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Center(
                    child: IconButton(
                      onPressed: () => showQuoteSheet(quote: quote),
                      icon: Icon(
                        Icons.more_horiz,
                        color: topicColor != null ?
                        Color(topicColor.decimal) : stateColors.primary,
                      ),
                    ),
                  ),

                  Padding(padding: const EdgeInsets.only(top: 10.0),),
                  Divider(),
                ],
              ),
            ),
          );
        },
        childCount: quotes.length,
      ),
    );
  }

  void quotidianAction(Quote quote) async {
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
      final snapshot = await Firestore.instance
        .collection('quotes')
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

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
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
    isLoadingMore = true;

    try {
      final snapshot = await Firestore.instance
        .collection('quotes')
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

        final quote = Quote.fromJSON(data);
        quotes.insert(quotes.length - 1, quote);
      });

      lastDoc = snapshot.documents.last;

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

  void getSavedLangAndOrder() {
    lang = appLocalStorage.getPageLang(pageRoute: QuotesRoute);
    descending = appLocalStorage.getPageOrder(pageRoute: QuotesRoute);
  }

  void showQuoteSheet({Quote quote}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 60.0,
          ),
          child: Wrap(
            spacing: 30.0,
            alignment: WrapAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  IconButton(
                    iconSize: 40.0,
                    tooltip: 'Delete',
                    onPressed: () {
                      FluroRouter.router.pop(context);
                      deleteAction(quote);
                    },
                    icon: Opacity(
                      opacity: .6,
                      child: Icon(
                        Icons.delete_outline,
                      ),
                    ),
                  ),

                  Text(
                    'Delete',
                  ),
                ],
              ),

              Column(
                children: <Widget>[
                  IconButton(
                    iconSize: 40.0,
                    onPressed: () {
                      FluroRouter.router.pop(context);
                      quotidianAction(quote);
                    },
                    icon: Opacity(
                      opacity: .6,
                      child: Icon(
                        Icons.star,
                      ),
                    ),
                  ),

                  Text(
                    'Add to quotidians',
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
