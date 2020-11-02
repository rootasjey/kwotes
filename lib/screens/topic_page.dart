import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/base_page_app_bar.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/components/side_bar_header.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/types/topic_color.dart';
import 'package:figstyle/utils/app_localstorage.dart';
import 'package:mobx/mobx.dart';

class TopicPage extends StatefulWidget {
  final String name;

  TopicPage({
    @required this.name,
  });

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  ///  Current State of InnerDrawerState
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  bool descending = true;
  bool hasNext = true;
  bool isFabVisible = false;
  bool isFav = false;
  bool isFavLoaded = false;
  bool isFavLoading = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool smallViewVisible = false;

  Color fabColor = Colors.amber;

  DocumentSnapshot lastDoc;

  final double beginY = 10.0;

  User userAuth;

  List<Quote> quotes = [];

  ReactionDisposer topicDisposer;

  ScrollController scrollController;

  String lang = 'en';
  String pageRoute;
  String topicName;

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
    final horPadding = MediaQuery.of(context).size.width < 700.00 ? 0.0 : 70.0;

    return BasePageAppBar(
      expandedHeight: 100.0,
      title: Padding(
        padding: EdgeInsets.only(
          left: horPadding,
        ),
        child: Row(
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
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                bottom: 4.0,
              ),
              child: Text(
                topicName,
                style: TextStyle(
                  fontSize: 40.0,
                  color: stateColors.foreground,
                ),
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
                  backgroundColor:
                      Color(appTopicsColors.find(topicName).decimal),
                ),
              ),
          ],
        ),
      ),
      bottom: Padding(
        padding: EdgeInsets.only(left: horPadding),
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
            ),
            child: Wrap(
              spacing: 15.0,
              children: <Widget>[
                if (smallViewVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: InkWell(
                        onTap: () {
                          _innerDrawerKey.currentState.toggle();
                        },
                        child: Icon(Icons.menu),
                      ),
                    ),
                  ),
                Padding(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bodyListContent() {
    if (isLoading || appTopicsColors.topicsColors.length == 0) {
      return loadingView();
    }

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

  Widget listView() {
    final horPadding = MediaQuery.of(context).size.width < 700.00 ? 0.0 : 70.0;

    return Observer(
      builder: (context) {
        final isConnected = userState.isUserConnected;

        return SliverPadding(
          padding: const EdgeInsets.only(top: 40.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final quote = quotes.elementAt(index);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 900.0,
                      ),
                      child: QuoteRowWithActions(
                        quote: quote,
                        quoteId: quote.id,
                        color: stateColors.appBackground,
                        isConnected: isConnected,
                        padding: EdgeInsets.symmetric(
                          horizontal: horPadding,
                          vertical: 10.0,
                        ),
                      ),
                    ),
                  ],
                );
              },
              childCount: quotes.length,
            ),
          ),
        );
      },
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

  Widget smallView() {
    final width = MediaQuery.of(context).size.width;
    final leftOffset = width < 500.00 ? 0.6 : 0.0;

    return InnerDrawer(
      key: _innerDrawerKey,
      tapScaffoldEnabled: true,
      offset: IDOffset.only(
        left: leftOffset,
      ),
      leftChild: Material(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: topicsItemsList(),
        ),
      ),
      scaffold: Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: mainContent(),
        ),
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
      title: Text(
        topicColor.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: topicColor.name == topicName
          ? Icon(Icons.keyboard_arrow_right)
          : null,
      // onTap: () => navigateToSection(topicColor.name),
      onTap: () {
        topicName = topicColor.name;
        initProps();
        fetchColor();
        fetch();

        final width = MediaQuery.of(context).size.width;
        if (width < 500.0) {
          _innerDrawerKey.currentState.close();
        }
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
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: mainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> fetchIsFav(String quoteId) async {
    isFavLoading = true;

    if (userAuth == null) {
      userAuth = FirebaseAuth.instance.currentUser;
    }

    if (userAuth == null) {
      return false;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('favourites')
          .doc(quoteId)
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
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('topics.$topicName', isEqualTo: true)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(10)
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

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.docs.last;

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
      final snapshot = await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicName)
          .get();

      if (snapshot == null || !snapshot.exists) {
        return;
      }

      setState(() {
        fabColor = Color(snapshot.data()['color']);
      });
    } catch (error) {}
  }

  void fetchMore() async {
    isLoadingMore = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('topics.$topicName', isEqualTo: true)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(10)
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

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.docs.last;

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
