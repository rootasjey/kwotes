import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/order_lang_button.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/converter.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:supercharged/supercharged.dart';

class Quotidians extends StatefulWidget {
  @override
  QuotidiansState createState() => QuotidiansState();
}

class QuotidiansState extends State<Quotidians> {
  bool canManage      = false;
  bool hasNext        = true;
  bool hasErrors      = false;
  bool isLoading      = false;
  bool isLoadingMore  = false;
  String lang         = 'en';
  int limit           = 30;
  bool descending     = false;
  final pageRoute     = QuotidiansRoute;

  List<Quotidian> quotidians = [];
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
      body: RefreshIndicator(
        onRefresh: () async {
          await fetch();
          return null;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollNotif) {
            if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent - 100.0) {
              return false;
            }

            if (hasNext && !isLoadingMore) {
              fetchMore();
            }

            return false;
          },
          child: bodyContent(),
        ),
      ),
    );
  }

  Widget appBar()  {
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
                      if (quotidians.length == 0) { return; }

                      scrollController.animateTo(
                        0,
                        duration: Duration(seconds: 2),
                        curve: Curves.easeOutQuint
                      );
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 60.0,
                      child: Text(
                        'Scheduled quotidians',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20.0,
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
                    appLocalStorage.savePageLang(
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

  Widget bodyContent() {
    return CustomScrollView(
      controller: scrollController,
      slivers: <Widget>[
        appBar(),
        customScrollViewChild(),
      ],
    );
  }

  Widget customScrollViewChild() {
    if (isLoading) {
      return loadingView();
    }

    if (quotidians.length == 0) {
      return emptyView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    return groupsList();
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

  Widget groupsList() {
    final Map<String, List<Quotidian>> groups = quotidians.groupBy(
      (quotidian) => '${quotidian.date.year}-${quotidian.date.month}',
    );

    final List<Widget> groupedList = [];

    groups.forEach((yearMonth, groupedQuotidians) {
      final singleGroup = monthGroup(yearMonth, groupedQuotidians);
      groupedList.addAll(singleGroup);
    });

    return SliverList(
      delegate: SliverChildListDelegate(groupedList),
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

  List<Widget> monthGroup(String yearMonth, List<Quotidian> group) {
    final splittedDate = yearMonth.split('-');

    final year = splittedDate[0];
    final month = getMonthFromNumber(splittedDate[1].toInt());

    final headerKey = GlobalKey();

    return [
      StickyHeader(
        key: headerKey,
        header: Container(
          color: stateColors.softBackground,
          child: FlatButton(
            onPressed: () {
              final renderObject = headerKey.currentContext.findRenderObject();
              renderObject.showOnScreen(duration: 1.seconds);
            },
            onLongPress: () => deleteMonth(group),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 35.0,
                bottom: 10.0,
              ),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      '$month $year',
                    ),

                    SizedBox(
                      width: 100.0,
                      child: Divider(thickness: 2,),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        content: sliverQuotesList(group),
      ),
    ];
  }

  Widget sliverQuotesList(List<Quotidian> group) {
    int index = 0;

    return Column(
      children: group.map((quotidian) {
        index++;

        final topicColor = appTopicsColors
          .find(quotidian.quote.topics.first);

        return FadeInY(
          delay: index * 1.0,
          beginY: 50.0,
          child: InkWell(
            onTap: () {
              FluroRouter.router.navigateTo(
                context,
                QuotePageRoute.replaceFirst(':id', quotidian.quote.id),
              );
            },
            onLongPress: () => showQuoteSheet(quotidian: quotidian),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(padding: const EdgeInsets.only(top: 20.0),),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    quotidian.quote.name,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),

                Center(
                  child: IconButton(
                    onPressed: () => showQuoteSheet(quotidian: quotidian),
                    icon: Icon(
                      Icons.more_horiz,
                      color: topicColor != null ?
                      Color(topicColor.decimal) : stateColors.primary,
                    ),
                  ),
                ),

                Center(
                  child: Opacity(
                    opacity: .6,
                    child: Text(
                      quotidian.date.day.toString(),
                    ),
                  ),
                ),

                Padding(padding: const EdgeInsets.only(top: 10.0),),
                Divider(),
              ],
            ),
          ),
        );
      }).toList()
    );
  }

  void deleteAction(Quotidian quotidian) async {
    try {
      await Firestore.instance
        .collection('quotidians')
        .document(quotidian.id)
        .delete();

      setState(() {
        quotidians.removeWhere((element) => element.id == quotidian.id);
      });

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'The quotidian has been successfully deleted.'
          ),
        )
      );

    } catch (error) {
      debugPrint(error.toString());

      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sorry, an error occurred while deleting the quotidian.'
          ),
        )
      );
    }
  }

  void deleteMonth(List<Quotidian> group) async {
    // NOTE: maybe do this job in a cloud function
    group.forEach((quotidian) async {
      await Firestore.instance
        .collection('quotidians')
        .document(quotidian.id)
        .delete();

      quotidians.removeWhere((element) => element.id == quotidian.id);
    });

    setState(() {});
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      quotidians.clear();
    });


    try {
      final snapshot = await Firestore.instance
        .collection('quotidians')
        .where('lang', isEqualTo: lang)
        .orderBy('date', descending: descending)
        .limit(limit)
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

        final quotidian = Quotidian.fromJSON(data);
        quotidians.add(quotidian);
      });

      lastDoc = snapshot.documents.last;

      setState(() {
        hasNext = snapshot.documents.length == limit;
        isLoading = false;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        hasNext = false;
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
      final snapshot = await Firestore.instance
        .collection('quotidians')
        .where('lang', isEqualTo: lang)
        .orderBy('date', descending: descending)
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

        final quotidian = Quotidian.fromJSON(data);
        quotidians.add(quotidian);
      });

      setState(() {
        hasNext = snapshot.documents.length == limit;
        lastDoc = snapshot.documents.last;
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
    lang = appLocalStorage.getPageLang(pageRoute: pageRoute);
    descending = appLocalStorage.getPageOrder(pageRoute: pageRoute);
  }

  void showQuoteSheet({Quotidian quotidian}) {
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
                      deleteAction(quotidian);
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
            ],
          ),
        );
      }
    );
  }
}
