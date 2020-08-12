import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/reference_row.dart';
import 'package:memorare/components/simple_appbar.dart';
import 'package:memorare/components/sliver_loading_view.dart';
import 'package:memorare/components/web/discover_card.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/home_app_bar.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class References extends StatefulWidget {
  @override
  _ReferencesState createState() => _ReferencesState();
}

class _ReferencesState extends State<References> {
  bool descending       = true;
  bool hasNext          = true;
  bool hasErrors        = false;
  bool isFabVisible     = false;
  bool isLoading        = false;
  bool isLoadingMore    = false;

  final referencesList = List<Reference>();

  final pageRoute         = ReferencesRoute;
  final scrollController  = ScrollController();

  int limit = 30;

  var itemsStyle = ItemsStyle.grid;
  var lastDoc;

  @override
  initState() {
    super.initState();
    initProps();
    fetch();
  }

  void initProps() {
    descending  = appLocalStorage.getPageOrder(pageRoute: pageRoute);
    itemsStyle  = appLocalStorage.getItemsStyle(pageRoute);
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

            // Load more scenario
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
              HomeAppBar(
                title: 'All references',
                automaticallyImplyLeading: true,
              ),

              appBar(),

              SliverPadding(padding: const EdgeInsets.only(top: 50.0)),
              bodyListContent(),
            ],
          ),
        )
      ),
    );
  }

  Widget appBar() {
    return SimpleAppBar(
      textTitle: 'Options',
      hideNavBackIcon: true,
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
                  tooltip: 'Order by first added',
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
                  tooltip: 'Order by most recently added',
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
                    color: stateColors.foreground.withOpacity(0.5),
                  ),
                ),
              ),

              FadeInY(
                beginY: 10.0,
                delay: 3.5,
                child: IconButton(
                  onPressed: () {
                    if (itemsStyle == ItemsStyle.list) {
                      return;
                    }

                    setState(() {
                      itemsStyle = ItemsStyle.list;
                    });

                    appLocalStorage.saveItemsStyle(
                      pageRoute: pageRoute,
                      style: ItemsStyle.list,
                    );
                  },
                  icon: Icon(Icons.list),
                  color: itemsStyle == ItemsStyle.list
                    ? stateColors.primary
                    : stateColors.foreground.withOpacity(0.5),
                ),
              ),

              FadeInY(
                beginY: 10.0,
                delay: 3.5,
                child: IconButton(
                  onPressed: () {
                    if (itemsStyle == ItemsStyle.grid) {
                      return;
                    }

                    setState(() {
                      itemsStyle = ItemsStyle.grid;
                    });

                    appLocalStorage.saveItemsStyle(
                      pageRoute: pageRoute,
                      style: ItemsStyle.grid,
                    );
                  },
                  icon: Icon(Icons.grid_on),
                  color: itemsStyle == ItemsStyle.grid
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

    if (referencesList.length == 0) {
      return emptyView();
    }

    if (itemsStyle == ItemsStyle.grid) {
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
            title: "There's was an issue while loading all references",
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

  Widget sliverGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250.0,
          childAspectRatio: 0.6,
          mainAxisSpacing: 30.0,
          crossAxisSpacing: 30.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final reference = referencesList.elementAt(index);

            return DiscoverCard(
              height: 260.0,
              width: 200.0,
              id: reference.id,
              imageUrl: reference.urls.image,
              name: reference.name,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                  )
                ),
              ],
              onSelected: (value) {
                if (value == 'share') {
                  shareReference(reference);
                  return;
                }
              },
            );
          },
          childCount: referencesList.length,
        ),
      ),
    );
  }

  Widget sliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final reference = referencesList.elementAt(index);

          return ReferenceRow(
            reference: reference,
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
                shareReference(reference);
                return;
              }
            },
          );
        },
        childCount: referencesList.length,
      ),
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      referencesList.clear();
    });

    try {
      final snapshot = await Firestore.instance
        .collection('references')
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

        final reference = Reference.fromJSON(data);
        referencesList.add(reference);
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

    isLoadingMore = true;
    print('load more');

    try {
      final snapshot = await Firestore.instance
        .collection('references')
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

        final reference = Reference.fromJSON(data);
        referencesList.add(reference);
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

  void shareReference(Reference reference) {
    if (kIsWeb) {
      shareReferenceWeb(reference);
      return;
    }

    shareReferenceMobile(reference);
  }

  void shareReferenceWeb(Reference reference) async {
    String sharingText = reference.name;
    final urlReference = 'https://outofcontext.app/#/reference/${reference.id}';

    if (reference.type.primary.isNotEmpty) {
      sharingText += ' (${reference.type.primary})';
    }

    final hashtags = '&hashtags=outofcontext';

    await launch(
      'https://twitter.com/intent/tweet?via=outofcontextapp&text=$sharingText$hashtags&url=$urlReference',
    );
  }

  void shareReferenceMobile(Reference reference) {
    final RenderBox box = context.findRenderObject();
    String sharingText = reference.name;
    final urlReference = 'https://outofcontext.app/#/reference/${reference.id}';

    if (reference.type.primary.isNotEmpty) {
      sharingText += ' (${reference.type.primary})';
    }

    sharingText += ' - URL: $urlReference';

    Share.share(
      sharingText,
      subject: 'Out Of Context',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }
}
