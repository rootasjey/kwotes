import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fig_style/router/app_router.gr.dart';
import 'package:fig_style/router/route_names.dart';
import 'package:fig_style/utils/app_storage.dart';
import 'package:fig_style/utils/constants.dart';
import 'package:fig_style/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fig_style/components/empty_view.dart';
import 'package:fig_style/components/page_app_bar.dart';
import 'package:fig_style/components/quote_row_with_actions.dart';
import 'package:fig_style/components/sliver_loading_view.dart';
import 'package:fig_style/components/topic_card_color.dart';
import 'package:fig_style/state/colors.dart';
import 'package:fig_style/state/topics_colors.dart';
import 'package:fig_style/state/user.dart';
import 'package:fig_style/types/quote.dart';
import 'package:fig_style/types/topic_color.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged/supercharged.dart';

List<TopicColor> _topicsList = [];

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  bool isFabVisible = false;
  bool isLoading = false;
  bool hasErrors = false;

  final limit = 3;
  final quotesByTopicsList = <List<Quote>>[];
  final pageRoute = RouteNames.TopicsRoute;

  ReactionDisposer topicsDisposer;

  ScrollController scrollController = ScrollController();

  String lang = 'en';

  @override
  initState() {
    super.initState();
    initProps();

    topicsDisposer = autorun((reaction) {
      if (_topicsList.length == 0) {
        _topicsList = appTopicsColors.shuffle(max: limit);
      }

      fetch();
    });
  }

  void initProps() async {
    lang = appStorage.getPageLang(pageRoute: pageRoute);

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    topicsDisposer?.reaction?.dispose();
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
          fetch();
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

            return false;
          },
          child: CustomScrollView(controller: scrollController, slivers: [
            appBar(),
            body(),
            moreTopicsButton(),
          ]),
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
      textTitle: 'Topics',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
        top: 24.0,
      ),
      bottomPadding: EdgeInsets.only(
        left: bottomContentLeftPadding,
        bottom: 20.0,
      ),
      lang: lang,
      onLangChanged: (String newLang) {
        lang = newLang;
        appStorage.setPageLang(lang: lang, pageRoute: pageRoute);
        fetch();
      },
      alwaysHideNavBackIcon: true,
      onTitlePressed: () {
        scrollController.animateTo(
          0,
          duration: 250.milliseconds,
          curve: Curves.easeIn,
        );
      },
    );
  }

  Widget body() {
    final width = MediaQuery.of(context).size.width;
    double horizontal = width < Constants.maxMobileWidth ? 0.0 : 70.0;

    if (isLoading) {
      return SliverLoadingView();
    }

    if (quotesByTopicsList.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            EmptyView(
              title: 'No quotes',
              description: 'No quotes found. Please try to refresh the page.',
              onRefresh: () => fetch(),
            ),
          ]),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
      ),
      sliver: topicsAndQuotes(),
    );
  }

  Widget moreTopicsButton() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              final topic = appTopicsColors.shuffle(max: 1)?.first;

              if (topic == null) {
                Snack.e(
                  context: context,
                  message:
                      "Couldn't navigate to topic page because topics list is empty",
                );
                return;
              }

              context.router.push(
                TopicsDeepRoute(
                  children: [
                    TopicPageRoute(
                      topicName: topic.name,
                    )
                  ],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              primary: stateColors.secondary,
            ),
            icon: Icon(Icons.open_in_new),
            label: Opacity(
              opacity: 0.6,
              child: Text('Discover more topics'),
            ),
          ),
        ),
      ])),
    );
  }

  Widget topicsAndQuotes() {
    return Observer(builder: (context) {
      final isConnected = stateUser.isUserConnected;
      final width = MediaQuery.of(context).size.width;

      bool showPopupMenuButton = false;
      double horizontal = 10.0;
      double quoteFontSize = 20.0;

      if (width < 390) {
        horizontal = 0.0;
        quoteFontSize = 16.0;
      }

      if (width > Constants.maxMobileWidth) {
        showPopupMenuButton = true;
        quoteFontSize = 26.0;
      }

      return SliverList(
        delegate: SliverChildListDelegate.fixed(_topicsList.map((topic) {
          final index = _topicsList.indexOf(topic);
          final color = appTopicsColors.getColorFor(topic.name);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopicCardColor(
                size: 50.0,
                elevation: 6.0,
                color: Color(topic.decimal),
                name: topic.name,
                style: TextStyle(
                  fontSize: 20.0,
                ),
                padding: const EdgeInsets.only(
                  top: 10.0,
                  left: 32.0,
                ),
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: quotesByTopicsList[index].map(
                    (quote) {
                      return QuoteRowWithActions(
                        quote: quote,
                        quoteFontSize: quoteFontSize,
                        color: stateColors.appBackground,
                        isConnected: isConnected,
                        key: ObjectKey(quote.id),
                        useSwipeActions: true,
                        showPopupMenuButton: showPopupMenuButton,
                        leading: Container(
                          width: 15.0,
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Container(
                            width: 5.0,
                            height: 100.0,
                            decoration: ShapeDecoration(
                              color: color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontal,
                        ),
                      );
                    },
                  ).toList()),
            ],
          );
        }).toList()),
      );
    });
  }

  void fetch() async {
    setState(() => isLoading = true);

    for (var i = 0; i < limit; i++) {
      await fetchTopicQuotes(i);
    }

    setState(() => isLoading = false);
  }

  Future fetchTopicQuotes(int index) async {
    try {
      final topicName = _topicsList[index].name;

      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('topics.$topicName', isEqualTo: true)
          .where('lang', isEqualTo: lang)
          .limit(3)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final quotes = <Quote>[];

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        quotes.add(Quote.fromJSON(data));
      });

      quotesByTopicsList.insert(index, quotes);
    } catch (error) {
      debugPrint(error.toString());
      hasErrors = true;
    }
  }
}
