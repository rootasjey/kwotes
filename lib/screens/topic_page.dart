import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memorare/components/app_icon.dart';
import 'package:memorare/components/circle_button.dart';
import 'package:memorare/components/quote_row_with_actions.dart';
import 'package:memorare/components/base_page_app_bar.dart';
import 'package:memorare/components/empty_content.dart';
import 'package:memorare/components/fade_in_y.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/side_bar_header.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/router/route_names.dart';
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
  ///  Current State of InnerDrawerState
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  final beginY = 10.0;

  bool descending = true;
  Color fabColor = Colors.amber;
  bool hasNext = true;
  bool isFabVisible = false;
  bool isFav = false;
  bool isFavLoaded = false;
  bool isFavLoading = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  String pageRoute;
  String lang = 'en';
  bool smallViewVisible = false;
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
    fetchColor();
    fetch();
  }

  void initProps() {
    if (scrollController != null) {
      scrollController.dispose();
    }

    scrollController = ScrollController();
    pageRoute = TopicRoute.replaceFirst(':name', topicName);

    final storageKey = '$pageRoute?lang';

    lang = appLocalStorage.containsKey(storageKey)
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
    return OrientationBuilder(
      builder: (context, orientation) {
        final screenWidth = MediaQuery.of(context).size.width;
        smallViewVisible = screenWidth < 1000.0;

        return smallViewVisible ? smallView() : wideView();
      },
    );
  }

  Widget appBar() {
    return BasePageAppBar(
      expandedHeight: 150.0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleButton(
            icon: Icon(
              Icons.arrow_back,
              color: stateColors.foreground,
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
          AppIcon(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            size: 30.0,
          ),
          Text(
            topicName,
            style: TextStyle(
              fontSize: 40.0,
            ),
          ),
          if (topicName.isNotEmpty && appTopicsColors.topicsColors.length > 0)
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 2.5,
              ),
              child: CircleAvatar(
                radius: 10.0,
                backgroundColor: Color(appTopicsColors.find(topicName).decimal),
              ),
            ),
        ],
      ),
      subHeader: Observer(
        builder: (context) {
          return Wrap(
            spacing: 10.0,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Opacity(
                  opacity: 0.6,
                  child: InkWell(
                    onTap: smallViewVisible
                        ? () {
                            _innerDrawerKey.currentState.toggle();
                          }
                        : null,
                    child: Icon(Icons.menu),
                  ),
                ),
              ),
              FadeInY(
                beginY: beginY,
                delay: 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
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
                      fontFamily: GoogleFonts.raleway().fontFamily,
                      fontSize: 20.0,
                    ),
                    onChanged: (String newLang) {
                      lang = newLang;
                      appLocalStorage.setPageLang(
                        lang: lang,
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

    return listView();
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 2.0,
          beginY: beginY,
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
      ]),
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

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: LoadingAnimation(
            textTitle: 'Loading $topicName quotes...',
          ),
        ),
      ]),
    );
  }

  Widget mainContent() {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              backgroundColor: fabColor,
              child: Icon(Icons.arrow_upward),
              onPressed: () {
                scrollController.animateTo(
                  0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              },
            )
          : null,
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
          if (scrollNotif.metrics.pixels <
              scrollNotif.metrics.maxScrollExtent - 100.0) {
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

  Widget listView() {
    final horPadding = MediaQuery.of(context).size.width < 700.00 ? 20.0 : 70.0;

    return Observer(
      builder: (context) {
        final isConnected = userState.isUserConnected;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final quote = quotes.elementAt(index);

              return QuoteRowWithActions(
                quote: quote,
                quoteId: quote.id,
                isConnected: isConnected,
                padding: EdgeInsets.symmetric(
                  horizontal: horPadding,
                ),
              );
            },
            childCount: quotes.length,
          ),
        );
      },
    );
  }

  Widget smallView() {
    return InnerDrawer(
      key: _innerDrawerKey,
      tapScaffoldEnabled: true,
      offset: IDOffset.only(
        left: 0.0,
      ),
      leftChild: Material(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: topicsItemsList(),
        ),
      ),
      scaffold: mainContent(),
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
          items.add(topicTileItem(topicColor: topicColor));
        });

        return ListView(
          children: <Widget>[
            if (!smallViewVisible)
              Padding(
                padding: const EdgeInsets.only(
                  top: 60.0,
                  bottom: 100.0,
                ),
                child: SideBarHeader(),
              ),
            ...items,
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
            ),
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
        fetchColor();
        fetch();
      },
    );
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
            child: mainContent(),
          ),
        ],
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
          .where('lang', isEqualTo: lang)
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

  void fetchColor() async {
    try {
      final snapshot = await Firestore.instance
          .collection('topics')
          .document(topicName)
          .get();

      if (snapshot == null || !snapshot.exists) {
        return;
      }

      setState(() {
        fabColor = Color(snapshot.data['color']);
      });
    } catch (error) {}
  }

  void fetchMore() async {
    isLoadingMore = true;

    try {
      final snapshot = await Firestore.instance
          .collection('quotes')
          .where('topics.$topicName', isEqualTo: true)
          .where('lang', isEqualTo: lang)
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

  void navigateToSection(String route) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => TopicPage(name: route)));
  }
}
