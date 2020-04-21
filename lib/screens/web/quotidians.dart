import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/sliver_appbar_delegate.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/colors.dart';
import 'package:memorare/utils/converter.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged/supercharged.dart';

class Quotidians extends StatefulWidget {
  @override
  _QuotidiansState createState() => _QuotidiansState();
}

class _QuotidiansState extends State<Quotidians> {
  List<Quotidian> quotidians = [];

  bool isCheckingAuth = false;
  bool isLoading      = false;
  bool isLoadingMore  = false;
  bool hasNext        = true;
  int limit           = 30;
  String selectedLang = 'en';

  final scrollController = ScrollController();
  bool isFabVisible = false;

  var lastDoc;

  ReactionDisposer colorDisposer;
  Color backgroundColor;

  @override
  initState() {
    super.initState();

    selectedLang = Language.frontend(appLocalStorage.getQuotidiansLang());

    colorDisposer = autorun((_) {
      final color = stateColors.background == Colors.black ?
        CustomColors.softDark : CustomColors.softLight;

      if (backgroundColor != color) {
        setState(() {
          backgroundColor = color;
        });
      }
    });

    checkAuth();
    fetchQuotidians();
  }

  @override
  void dispose() {
    if (colorDisposer != null) { colorDisposer(); }
    super.dispose();
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
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: body(),
          ),

          Column(
            children: <Widget>[
              if (hasNext)
                loadMoreButton(),
              NavBackFooter(),
            ],
          ),

          Footer(),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return FullPageLoading(
        title: 'Loading quotidians...',
      );
    }

    if (!isLoading && quotidians.length == 0) {
      return emptyContainer();
    }

    return gridQuotes();
  }

  Widget emptyContainer() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          Icon(Icons.warning, size: 40.0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('No quotidians found. Either the service has trouble or your connection does not work properly.'),
          ),
        ],
      ),
    );
  }

  Widget gridQuotes() {
    final Map<String, List<Quotidian>> groups = quotidians.groupBy(
      (quotidian) => '${quotidian.date.year}-${quotidian.date.month}',
    );

    final List<Widget> groupedGrids = [];

    groups.forEach((key, value) {
      final grid = groupGrid(key, value);
      groupedGrids.addAll(grid);
    });

    return NotificationListener<ScrollNotification>(
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
        if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent - 100.0) {
          return false;
        }

        if (hasNext && !isLoadingMore) {
          fetchMoreQuotidians();
        }

        return false;
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 340.0,
            // backgroundColor: Colors.transparent,
            // backgroundColor: stateColors.primary,
            backgroundColor: backgroundColor,
            automaticallyImplyLeading: false,
            flexibleSpace: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FadeInY(
                      beginY: 50.0,
                      child: AppIconHeader(),
                    ),

                    FadeInY(
                      delay: 1.0,
                      beginY: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Quotidians',
                            style: TextStyle(
                              fontSize: 30.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    FadeInY(
                      delay: 1.4,
                      beginY: 50.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: DropdownButton<String>(
                          elevation: 3,
                          value: selectedLang,
                          onChanged: (String newValue) {
                            setState(() {
                              selectedLang = newValue;
                            });

                            fetchQuotidians();
                            appLocalStorage.saveQuotidiansLang(Language.backend(selectedLang));
                          },
                          items: ['English', 'Français']
                            .map((String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    // color: Colors.white,
                                    // backgroundColor: stateColors.primary,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  left: 80.0,
                  top: 80.0,
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
          ),

          ...groupedGrids,
        ],
      ),
    );
  }

  List<Widget> groupGrid(String yearMonth, List<Quotidian> grouped) {
    final splittedDate = yearMonth.split('-');

    final year = splittedDate[0];
    final month = getMonthFromNumber(splittedDate[1].toInt());

    return [
      SliverPersistentHeader(
        pinned: true,
        floating: true,
        delegate: SliverAppBarDelegate(
          minHeight: 60.0,
          maxHeight: 100.0,
          child: Container(
            padding: const EdgeInsets.only(top: 20.0),
            color: backgroundColor,
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(
                    '$month $year',
                  ),

                  SizedBox(
                    width: 100.0,
                    child: Divider(thickness: 2,),
                  )
                ],
              ),
            ),
          ),
        ),
      ),

      SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final quote = grouped.elementAt(index);

            return FadeInY(
              delay: 3.0 + index.toDouble(),
              beginY: 100.0,
              child: SizedBox(
                width: 250.0,
                height: 250.0,
                child: gridItem(quote),
              ),
            );
          },
          childCount: grouped.length,
        ),
      ),
    ];
  }

  Widget gridItem(Quotidian quotidian) {
    final quote = quotidian.quote;
    final topicColor = appTopicsColors.find(quote.topics.first);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          FluroRouter.router.navigateTo(
            context,
            QuotePageRoute.replaceFirst(':id', quotidian.id)
          );
        },
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    quote.name.length > 115 ?
                      '${quote.name.substring(0, 115)}...' : quote.name,
                    style: TextStyle(
                      fontSize: adaptativeFont(quote.name),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 0,
              bottom: 0,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: Color(topicColor.decimal),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    deleteQuotidian(quotidian);
                    return;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    )
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 15.0,
              right: 60.0,
              child: Text(
                quotidian.date.day.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loadMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
        child: FlatButton(
        onPressed: () {
          fetchMoreQuotidians();
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: stateColors.foreground,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            'Load more...'
          ),
        ),
      ),
    );
  }

  double adaptativeFont(String text) {
    if (text.length > 120) {
      return 14.0;
    }

    if (text.length > 90) {
      return 16.0;
    }

    if (text.length > 60) {
      return 18.0;
    }

    return 20.0;
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isCheckingAuth = false;
        });

        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      setState(() {
        isCheckingAuth = false;
      });

    } catch (error) {
      isCheckingAuth = false;
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void deleteQuotidian(Quotidian quotidian) async {
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

  void fetchQuotidians() async {
    setState(() {
      isLoading = true;
    });

    quotidians.clear();

    final lang = Language.backend(selectedLang);

    try {
      final snapshot = await Firestore.instance
        .collection('quotidians')
        .where('lang', isEqualTo: lang)
        .orderBy('date', descending: false)
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

  void fetchMoreQuotidians() async {
    if (lastDoc == null) {
      return;
    }

    isLoadingMore = true;
    final lang = Language.backend(selectedLang);

    try {
      final snapshot = await Firestore.instance
        .collection('quotidians')
        .where('lang', isEqualTo: lang)
        .orderBy('date', descending: false)
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
}
