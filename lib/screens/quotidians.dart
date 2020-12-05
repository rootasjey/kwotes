import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/quotidian_row.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quotidian.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/auth.dart';
import 'package:figstyle/utils/converter.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:supercharged/supercharged.dart';

class Quotidians extends StatefulWidget {
  @override
  QuotidiansState createState() => QuotidiansState();
}

class QuotidiansState extends State<Quotidians> {
  bool canManage = false;
  bool hasNext = true;
  bool hasErrors = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  var itemsLayout = ItemsLayout.list;
  String lang = 'en';
  int limit = 30;
  bool descending = false;
  final pageRoute = QuotidiansRoute;

  List<Quotidian> quotidians = [];
  ScrollController scrollController = ScrollController();

  var lastDoc;

  @override
  initState() {
    super.initState();
    checkConnectedOrNavSignin(context: context);
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
      body: RefreshIndicator(
        onRefresh: () async {
          await fetch();
          return null;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollNotif) {
            if (scrollNotif.metrics.pixels <
                scrollNotif.metrics.maxScrollExtent - 100.0) {
              return false;
            }

            if (hasNext && !isLoadingMore) {
              fetchMore();
            }

            return false;
          },
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => LayoutBuilder(
                  builder: (context, constrains) {
                    return body(
                      maxWidth: constrains.maxWidth,
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
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
      textTitle: 'Quotidians',
      textSubTitle: 'Scheduled quotes for the coming days',
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

  Widget body({double maxWidth}) {
    return CustomScrollView(
      controller: scrollController,
      slivers: <Widget>[
        appBar(),
        if (itemsLayout == ItemsLayout.list) customScrollViewChild(),
        if (itemsLayout == ItemsLayout.grid) ...groupedGrids(),
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

    return groupedLists();
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

  List<Widget> groupedGrid(String yearMonth, List<Quotidian> grouped) {
    final headerKey = GlobalKey();

    return [
      SliverStickyHeader(
        header: headerGroup(
          headerKey: headerKey,
          yearMonth: yearMonth,
          group: grouped,
        ),
        sliver: SliverPadding(
          key: headerKey,
          padding: const EdgeInsets.all(10.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350.0,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final quote = grouped.elementAt(index);
                return itemGrid(quote);
              },
              childCount: grouped.length,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> groupedGrids() {
    final List<Widget> widgets = [];

    if (isLoading) {
      widgets.add(loadingView());
      return widgets;
    }

    if (quotidians.length == 0) {
      widgets.add(emptyView());
      return widgets;
    }

    if (!isLoading && hasErrors) {
      widgets.add(errorView());
      return widgets;
    }

    final Map<String, List<Quotidian>> groups = quotidians.groupBy(
      (quotidian) => '${quotidian.date.year}-${quotidian.date.month}',
    );

    groups.forEach((yearMonth, groupedQuotidians) {
      final grid = groupedGrid(yearMonth, groupedQuotidians);
      widgets.addAll(grid);
    });

    return widgets;
  }

  List<Widget> groupedList(String yearMonth, List<Quotidian> group) {
    final headerKey = GlobalKey();

    return [
      StickyHeader(
        key: headerKey,
        header: headerGroup(
          headerKey: headerKey,
          yearMonth: yearMonth,
          group: group,
        ),
        content: itemList(group),
      ),
    ];
  }

  Widget groupedLists() {
    final Map<String, List<Quotidian>> groups = quotidians.groupBy(
      (quotidian) => '${quotidian.date.year}-${quotidian.date.month}',
    );

    final List<Widget> widgets = [];

    groups.forEach((yearMonth, groupedQuotidians) {
      final singleGroup = groupedList(yearMonth, groupedQuotidians);
      widgets.addAll(singleGroup);
    });

    return SliverList(
      delegate: SliverChildListDelegate(widgets),
    );
  }

  Widget headerGroup({
    GlobalKey<State<StatefulWidget>> headerKey,
    String yearMonth,
    List<Quotidian> group,
  }) {
    final splittedDate = yearMonth.split('-');

    final year = splittedDate[0];
    final month = getMonthFromNumber(splittedDate[1].toInt());

    return Material(
      elevation: 2.0,
      color: stateColors.softBackground,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            FlatButton(
              onPressed: () {
                final renderObject =
                    headerKey.currentContext.findRenderObject();
                renderObject.showOnScreen(duration: 1.seconds);
              },
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
                        child: Divider(
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0.0,
              child: FlatButton(
                onPressed: () {
                  deleteMonthDialog(
                    yearMonth,
                    group,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 25.0,
                  ),
                  child: Icon(
                    Icons.delete,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemGrid(Quotidian quotidian) {
    return QuotidianRow(
      quotidian: quotidian,
      padding: EdgeInsets.zero,
      elevation: 2.0,
      componentType: ItemComponentType.card,
      onBeforeDelete: () {
        setState(() {
          quotidians.removeWhere((qItem) => qItem.id == quotidian.id);
        });
      },
      onAfterDelete: (bool success) {
        if (!success) {
          final index =
              quotidians.indexWhere((qItem) => qItem.id == quotidian.id);

          setState(() {
            quotidians.insert(index, quotidian);
          });
        }
      },
    );
  }

  /// Contains multiple children in a Column.
  Widget itemList(List<Quotidian> group) {
    final width = MediaQuery.of(context).size.width;
    double horizontal = width < Constants.maxMobileWidth ? 0.0 : 70.0;

    return Column(
        children: group.map((quotidian) {
      return QuotidianRow(
        quotidian: quotidian,
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        useSwipeActions: true,
        key: ObjectKey(quotidian.id),
        componentType: ItemComponentType.row,
        onBeforeDelete: () {
          setState(() {
            quotidians.removeWhere((qItem) => qItem.id == quotidian.id);
          });
        },
        onAfterDelete: (bool success) {
          if (!success) {
            final index =
                quotidians.indexWhere((qItem) => qItem.id == quotidian.id);

            setState(() {
              quotidians.insert(index, quotidian);
            });
          }
        },
      );
    }).toList());
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

  void deleteMonth(List<Quotidian> group) async {
    // NOTE: maybe do this job in a cloud function
    group.forEach((quotidian) async {
      await FirebaseFirestore.instance
          .collection('quotidians')
          .doc(quotidian.id)
          .delete();

      setState(() {
        quotidians.removeWhere((element) => element.id == quotidian.id);
      });
    });
  }

  void deleteMonthDialog(String yearMonth, List<Quotidian> grouped) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Delete $yearMonth group?',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
            actionsPadding: const EdgeInsets.all(10.0),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Divider(
                    thickness: 1.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: <Widget>[
                        Opacity(
                          opacity: .6,
                          child: Text(
                            'This action cannot be undone.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: stateColors.foreground.withOpacity(.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  deleteMonth(grouped);
                },
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    'DELETE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      quotidians.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotidians')
          .where('lang', isEqualTo: lang)
          .orderBy('date', descending: descending)
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

        final quotidian = Quotidian.fromJSON(data);
        quotidians.add(quotidian);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        hasNext = snapshot.docs.length == limit;
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
      final snapshot = await FirebaseFirestore.instance
          .collection('quotidians')
          .where('lang', isEqualTo: lang)
          .orderBy('date', descending: descending)
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

        final quotidian = Quotidian.fromJSON(data);
        quotidians.add(quotidian);
      });

      setState(() {
        hasNext = snapshot.docs.length == limit;
        lastDoc = snapshot.docs.last;
        isLoadingMore = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
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
                        Navigator.of(context).pop();
                        // deleteAction(quotidian);
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
        });
  }
}
