import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/persistent_header.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/author_row.dart';
import 'package:figstyle/components/circle_author.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/reference_row.dart';
import 'package:figstyle/components/sliver_loading_view.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/reference_card.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged/supercharged.dart';

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  bool descending = true;
  bool hasNext = true;
  bool hasErrors = false;
  bool isFabVisible = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  Color persistentHeaderColor;

  DiscoverType discoverType = DiscoverType.references;

  DocumentSnapshot lastDoc;

  final double narrowWidthLimit = 390.0;

  final limit = 30;
  final scrollController = ScrollController();
  final pageRoute = 'DiscoverRoute';

  ItemsLayout itemsLayout;
  List<Author> authors = [];
  List<Reference> references = [];

  String lang = 'en';

  ReactionDisposer reactionDisposer;

  @override
  void initState() {
    super.initState();
    initProps();

    if (discoverType == DiscoverType.references && references.length > 0) {
      return;
    }

    if (discoverType == DiscoverType.authors && authors.length > 0) {
      return;
    }

    fetch();
  }

  void initProps() {
    lang = appStorage.getPageLang(pageRoute: pageRoute);
    descending = appStorage.getPageOrder(pageRoute: pageRoute);
    itemsLayout = appStorage.getItemsStyle(pageRoute);
    discoverType = appStorage.getDiscoverType();

    persistentHeaderColor = stateColors.softBackground;

    reactionDisposer = autorun((_) {
      persistentHeaderColor = stateColors.softBackground;
    });
  }

  @override
  dispose() {
    reactionDisposer?.reaction?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
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
              setState(() {
                isFabVisible = false;
              });
            } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
              setState(() {
                isFabVisible = true;
              });
            }

            if (scrollNotif.metrics.pixels <
                scrollNotif.metrics.maxScrollExtent) {
              return false;
            }

            if (hasNext && !isLoadingMore) {
              fetchMore();
            }

            return false;
          },
          child: SafeArea(
            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                appBar(),
                appBarType(),
                body(),
              ],
            ),
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
      titleLeftPadding = 16.0;
      bottomContentLeftPadding = 24.0;
    }

    return PageAppBar(
      textTitle: 'Discover',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
        top: 24.0,
      ),
      bottomPadding: EdgeInsets.only(
        left: bottomContentLeftPadding,
        bottom: 10.0,
      ),
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

  Widget appBarType() {
    final isReferencesSelected = discoverType == DiscoverType.references;
    final width = MediaQuery.of(context).size.width;
    double left = width < Constants.maxMobileWidth ? 32.0 : 86.0;

    return SliverPersistentHeader(
      pinned: true,
      delegate: PersistentHeader(
        color: persistentHeaderColor,
        child: Padding(
          padding: EdgeInsets.only(left: left),
          child: Wrap(
            spacing: 10.0,
            children: [
              Opacity(
                opacity: isReferencesSelected ? 1.0 : 0.5,
                child: TextButton(
                  onPressed: () {
                    appStorage.saveDiscoverType(DiscoverType.references);
                    setState(() => discoverType = DiscoverType.references);
                    fetch();
                  },
                  style: TextButton.styleFrom(
                    primary: isReferencesSelected
                        ? stateColors.secondary
                        : stateColors.foreground,
                  ),
                  child: Text(
                    'References',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: isReferencesSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: !isReferencesSelected ? 1.0 : 0.5,
                child: TextButton(
                  onPressed: () {
                    appStorage.saveDiscoverType(DiscoverType.authors);
                    setState(() => discoverType = DiscoverType.authors);
                    fetch();
                  },
                  style: TextButton.styleFrom(
                    primary: !isReferencesSelected
                        ? stateColors.secondary
                        : stateColors.foreground,
                  ),
                  child: Text(
                    'Authors',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: !isReferencesSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return SliverLoadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if ((discoverType == DiscoverType.references && references.length == 0) ||
        (discoverType == DiscoverType.authors && authors.length == 0)) {
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
          delay: 100.milliseconds,
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
            title: "There's was an issue while loading discover page",
            subtitle: 'Check your connection an try to refresh this page',
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
    if (discoverType == DiscoverType.authors) {
      return gridViewAuthors();
    }

    return gridViewReferences();
  }

  Widget gridViewAuthors() {
    final width = MediaQuery.of(context).size.width;
    double childAspectRatio = 0.77;
    double maxCrossAxisExtent = 250.0;

    if (width < Constants.maxMobileWidth) {
      childAspectRatio = 0.67;
      maxCrossAxisExtent = 200.0;
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        vertical: 40.0,
        horizontal: 20.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final author = authors.elementAt(index);

            return CircleAuthor(author: author);
          },
          childCount: authors.length,
        ),
      ),
    );
  }

  Widget gridViewReferences() {
    final width = MediaQuery.of(context).size.width;
    double childAspectRatio = 0.76;
    double maxCrossAxisExtent = 300.0;

    double refCardHeight = 260.0;
    double refCardWidth = 200.0;
    double vertical = 100.0;
    double horizontal = 40.0;

    if (width < Constants.maxMobileWidth) {
      vertical = 20.0;
      horizontal = 20.0;
      childAspectRatio = 0.54;
      maxCrossAxisExtent = 200.0;
      refCardHeight = 200.0;
      refCardWidth = 200.0;
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        vertical: vertical,
        horizontal: horizontal,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final reference = references[index];

            return ReferenceCard(
              height: refCardHeight,
              width: refCardWidth,
              id: reference.id,
              imageUrl: reference.urls.image,
              name: reference.name,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Share'),
                    )),
              ],
              onSelected: (value) {
                if (value == 'share') {
                  ShareActions.shareReference(
                    context: context,
                    reference: reference,
                  );
                  return;
                }
              },
            );
          },
          childCount: references.length,
        ),
      ),
    );
  }

  Widget listView() {
    if (discoverType == DiscoverType.authors) {
      return listViewAuthors();
    }

    return listViewReferences();
  }

  Widget listViewAuthors() {
    final width = MediaQuery.of(context).size.width;
    double horPadding = width < 700.0 ? 0.0 : 70.0;
    bool isNarrow = false;

    if (width < narrowWidthLimit) {
      isNarrow = true;
      horPadding = 0.0;
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final author = authors.elementAt(index);

          return AuthorRow(
            author: author,
            isNarrow: isNarrow,
            key: ObjectKey(index),
            useSwipeActions: width < Constants.maxMobileWidth,
            padding: EdgeInsets.symmetric(
              horizontal: horPadding,
            ),
          );
        },
        childCount: authors.length,
      ),
    );
  }

  Widget listViewReferences() {
    final width = MediaQuery.of(context).size.width;

    double horPadding = width < 700.0 ? 0.0 : 70.0;
    bool isNarrow = false;

    if (width < narrowWidthLimit) {
      isNarrow = true;
      horPadding = 0.0;
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final reference = references.elementAt(index);

          return ReferenceRow(
            reference: reference,
            isNarrow: isNarrow,
            key: ObjectKey(index),
            useSwipeActions: width < Constants.maxMobileWidth,
            padding: EdgeInsets.symmetric(
              horizontal: horPadding,
            ),
          );
        },
        childCount: references.length,
      ),
    );
  }

  List<Widget> cardsList() {
    List<Widget> cards = [];
    int index = 0;

    for (var reference in references) {
      cards.add(FadeInY(
        delay: Duration(milliseconds: index * 100),
        beginY: 100.0,
        child: ReferenceCard(
          elevation: 5.0,
          height: 240.0,
          id: reference.id,
          imageUrl: reference.urls.image,
          name: reference.name,
          titleFontSize: 15.0,
          type: 'reference',
          width: 170.0,
        ),
      ));

      index++;
    }

    return cards;
  }

  Future fetch() {
    if (discoverType == DiscoverType.authors) {
      return fetchAuthors();
    }

    return fetchReferences();
  }

  Future fetchMore() {
    if (discoverType == DiscoverType.authors) {
      return fetchMoreAuthors();
    }

    return fetchMoreReferences();
  }

  Future fetchAuthors() async {
    setState(() {
      authors.clear();
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('authors')
          .orderBy('updatedAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        print('empty authors');
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final author = Author.fromJSON(data);
        authors.add(author);
      });

      if (!this.mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        hasNext = snapshot.docs.isNotEmpty;
        lastDoc = snapshot.docs.last;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  Future fetchMoreAuthors() async {
    if (lastDoc == null) {
      return;
    }

    isLoadingMore = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('authors')
          .orderBy('updatedAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        hasNext = false;
        isLoadingMore = false;
        return;
      }

      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          final data = doc.data();
          data['id'] = doc.id;

          final author = Author.fromJSON(data);
          authors.add(author);
        });
      }

      setState(() {
        isLoadingMore = false;
        hasNext = snapshot.docs.isNotEmpty;
        lastDoc = snapshot.docs.last;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future fetchReferences() async {
    setState(() {
      references.clear();
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('references')
          .orderBy('updatedAt', descending: descending)
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

        final ref = Reference.fromJSON(data);
        references.add(ref);
      });

      if (!this.mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        hasNext = snapshot.docs.isNotEmpty;
        lastDoc = snapshot.docs.last;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  Future fetchMoreReferences() async {
    if (lastDoc == null) {
      return;
    }

    isLoadingMore = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('references')
          .orderBy('updatedAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        hasNext = false;
        isLoadingMore = false;
        return;
      }

      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          final data = doc.data();
          data['id'] = doc.id;

          final ref = Reference.fromJSON(data);
          references.add(ref);
        });
      }

      setState(() {
        isLoadingMore = false;
        hasNext = snapshot.docs.isNotEmpty;
        lastDoc = snapshot.docs.last;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
