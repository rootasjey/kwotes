import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/quote_row.dart';
import 'package:memorare/components/simple_appbar.dart';
import 'package:memorare/components/web/add_to_list_button.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/side_bar_header.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/types/topic_color.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:mobx/mobx.dart';

class TopicPage extends StatefulWidget {
  final String name;

  TopicPage({
    this.name,
  });

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final beginY        = 50.0;
  final delay         = 1.0;
  final delayStep     = 1.2;

  bool descending     = true;
  bool hasNext        = true;
  bool isFabVisible   = false;
  bool isFav          = false;
  bool isFavLoaded    = false;
  bool isFavLoading   = false;
  bool isLoading      = false;
  bool isLoadingMore  = false;

  String selectedLang = 'en';
  String pageRoute;
  String topicName;

  var lastDoc;
  ScrollController scrollController;
  List<Quote> quotes = [];
  ReactionDisposer topicDisposer;
  FirebaseUser userAuth;

  @override
  void initState() {
    super.initState();

    topicName = widget.name.toLowerCase();

    initProps();
    fetch();
  }

  void initProps() {
    if (scrollController != null) {
      scrollController.dispose();
    }

    scrollController = ScrollController();
    pageRoute = TopicRoute.replaceFirst(':name', topicName);

    final storageKey = '$pageRoute?lang';

    selectedLang = appLocalStorage.containsKey(storageKey)
      ? appLocalStorage.getPageLang(pageRoute: pageRoute)
      : userState.lang;
  }

  @override
  void dispose() {
    if (topicDisposer != null) {
      topicDisposer();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return wideView();
  }

  Widget wideView() {
    return Material(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              foregroundDecoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.05),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: topicsItemsList(),
            ),
          ),

          Expanded(
            flex: 3,
            child: body(),
          ),
        ],
      ),
    );
  }

  Widget body() {
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
          child: Icon(Icons.arrow_upward),
        ) : null,
      body: NotificationListener<ScrollNotification>(
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
      ),
    );
  }

  Widget appBar() {
    return SimpleAppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(topicName, style: TextStyle(fontSize: 40.0,),),
          Padding(padding: const EdgeInsets.only(left: 20.0),),

          if (topicName.isNotEmpty && appTopicsColors.topicsColors.length > 0)
            CircleAvatar(
              radius: 10.0,
              backgroundColor: Color(appTopicsColors.find(topicName).decimal),
            ),
        ],
      ),
      subHeader: Observer(
        builder: (context) {
          return Wrap(
            spacing: 10.0,
            children: <Widget>[
              FadeInY(
                beginY: 10.0,
                delay: 1.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: DropdownButton<String>(
                    elevation: 2,
                    value: selectedLang,
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
                      selectedLang = newLang;
                      appLocalStorage.setPageLang(
                        lang: selectedLang,
                        pageRoute: pageRoute,
                      );

                      fetch();
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
            ],
          );
        },
      ),
    );
  }

  Widget bodyListContent() {
    if (isLoading || appTopicsColors.topicsColors.length == 0) {
      return loadingView();
    }

    // if (!isLoading && hasErrors) {
    //   return errorView();
    // }

    if (quotes.length == 0) {
      return emptyView();
    }

    return sliverQuotesList();
  }

  Widget sliverQuotesList() {
    return Observer(
      builder: (context) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final quote = quotes.elementAt(index);

              final popupMenuItems = <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                  )
                ),
              ];

              if (userState.isUserConnected) {
                popupMenuItems.addAll([
                  PopupMenuItem(
                    value: 'favourites',
                    child: ListTile(
                      leading: Icon(Icons.favorite_border),
                      title: Text('Add to favourites'),
                    ),
                  ),

                  PopupMenuItem(
                    value: 'list',
                    child: AddToListButton(
                      type: ButtonType.tile,
                      quote: quote,
                    ),
                  ),
                ]);
              }

              return QuoteRow(
                quote: quote,
                itemBuilder: (context) => popupMenuItems,
                onSelected: (value) {
                  switch (value) {
                    case 'favourites':
                      addToFavourites(
                        context: context,
                        quote: quote,
                      );
                      break;
                    case 'share':
                      shareTwitter(quote: quote);
                      break;
                    default:
                  }
                },
              );
            },
            childCount: quotes.length,
          ),
        );
      },
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
          LoadingAnimation(
            textTitle: 'Loading $topicName quotes...',
          ),
        ]
      ),
    );
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
          FadeInY(
            delay: 2.0,
            beginY: 50.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: EmptyContent(
                icon: Opacity(
                  opacity: .8,
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 60.0,
                    color: Color(0xFFFF005C),
                  ),
                ),
                title: "There's no quotes for $topicName at this moment",
                subtitle: 'You can help us and propose some',
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget gridQuotesContent() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          // final quote = quotes.elementAt(index);

          return SizedBox(
            width: 250.0,
            height: 250.0,
            child: null,
          );
        },
        childCount: quotes.length,
      ),
    );
  }

  Widget topicsItemsList() {
    return Observer(
      builder: (context) {
        final items = [];

        if (appTopicsColors.topicsColors.length == 0) {
          items.add(
            Center(child: CircularProgressIndicator()),
          );
        }

        appTopicsColors.topicsColors.forEach((topicColor) {
          items.add(
            topicTileItem(topicColor: topicColor)
          );
        });

        return ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 60.0,
                bottom: 100.0,
              ),
              child: SideBarHeader(),
            ),

            ...items,

            Padding(padding: const EdgeInsets.only(bottom: 100.0),),
          ],
        );
      },
    );
  }

  Widget topicTileItem({TopicColor topicColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: CircleAvatar(
        radius: 10.0,
        backgroundColor: Color(topicColor.decimal),
      ),
      title: Text(topicColor.name),
      trailing: topicColor.name == topicName
        ? Icon(Icons.keyboard_arrow_right)
        : null,
      // onTap: () => navigateToSection(topicColor.name),
      onTap: () {
        topicName = topicColor.name;
        initProps();
        fetch();
      },
    );
  }

  void navigateToSection(String route) {
    FluroRouter.router.navigateTo(
      context,
      TopicRoute.replaceFirst(':name', route),
      transition: TransitionType.fadeIn,
    );
  }

  Widget loadMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
        child: FlatButton(
        onPressed: () {
          fetchMore();
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(),
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

  Future<bool> fetchIsFav(String quoteId) async {
    isFavLoading = true;

    if (userAuth == null) {
      userAuth = await FirebaseAuth.instance.currentUser();
    }

    if (userAuth == null) {
      return false;
    }

    try {
      final doc = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('favourites')
        .document(quoteId)
        .get();

      setState(() {
        isFav = doc.exists;
        isFavLoading = false;
      });

      return true;

    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    quotes.clear();
    lastDoc = null;
    hasNext = true;

    try {
      final snapshot = await Firestore.instance
        .collection('quotes')
        .where('topics.$topicName', isEqualTo: true)
        .where('lang', isEqualTo: selectedLang)
        .orderBy('createdAt', descending: descending)
        .limit(10)
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
    isLoadingMore = true;

    try {
      final snapshot = await Firestore.instance
        .collection('quotes')
        .where('topics.$topicName', isEqualTo: true)
        .where('lang', isEqualTo: selectedLang)
        .orderBy('createdAt', descending: descending)
        .startAfterDocument(lastDoc)
        .limit(10)
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
        quotes.add(quote);
      });

      lastDoc = snapshot.documents.last;

      setState(() {
        isLoadingMore = false;
      });

    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void showActionsSheet(Quote quote) {
    isFav = false;
    isFavLoaded = false;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            if (!isFavLoading && !isFavLoaded) {
              fetchIsFav(quote.id)
                .then((isOk) {
                  stateSetter(() {
                    isFavLoaded = isOk;
                  });
                });
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: IconButton(
                      onPressed: () {
                        shareTwitter(quote: quote);
                      },
                      tooltip: 'Share',
                      icon: Icon(Icons.share),
                    ),
                  ),

                  isFav ?
                  IconButton(
                    onPressed: isFavLoaded ?
                      () {
                        removeFromFavourites(context: context, quote: quote);
                        Navigator.pop(context);
                      } : null,
                    tooltip: 'Remove from favourites',
                    icon: Icon(Icons.favorite),
                  ) :
                  IconButton(
                    onPressed: isFavLoaded ?
                      () {
                        addToFavourites(context: context, quote: quote);
                        Navigator.pop(context);
                      } : null,
                    tooltip: 'Add to favourites',
                    icon: Icon(Icons.favorite_border,)
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: IconButton(
                      onPressed: null,
                      tooltip: 'Add to...',
                      icon: Icon(Icons.playlist_add),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
