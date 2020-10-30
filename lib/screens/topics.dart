import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/screens/topic_page.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/components/empty_view.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/sliver_loading_view.dart';
import 'package:figstyle/components/topic_card_color.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/topic_color.dart';
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

  ScrollController scrollController = ScrollController();

  ReactionDisposer colorDisposer;

  String selectedLang = 'en';

  @override
  initState() {
    super.initState();

    colorDisposer = autorun((reaction) {
      if (_topicsList.length == 0) {
        _topicsList = appTopicsColors.shuffle(max: limit);
      }
      fetch();
    });
  }

  @override
  void dispose() {
    super.dispose();
    colorDisposer?.reaction?.dispose();
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
    if (MediaQuery.of(context).size.width < 700.0) {
      return PageAppBar(
        title: TextButton.icon(
          onPressed: () {
            scrollController.animateTo(
              0,
              duration: 250.milliseconds,
              curve: Curves.easeIn,
            );
          },
          icon: AppIcon(
            padding: EdgeInsets.zero,
            size: 30.0,
          ),
          label: Text(
            'Topics',
            style: TextStyle(
              fontSize: 22.0,
            ),
          ),
        ),
        expandedHeight: 80.0,
        showNavBackIcon: false,
        onTitlePressed: () {
          scrollController.animateTo(
            0,
            duration: 250.milliseconds,
            curve: Curves.easeIn,
          );
        },
      );
    }

    return SliverPadding(
      padding: EdgeInsets.zero,
    );
  }

  Widget body() {
    if (isLoading) {
      return SliverLoadingView();
    }

    if (quotesByTopicsList.isEmpty) {
      return SliverList(
          delegate: SliverChildListDelegate.fixed([
        EmptyView(
          title: 'No quotes',
          description: 'No quotes found. Please try to refresh the page.',
          onRefresh: () => fetch(),
        ),
      ]));
    }

    return topicsAndQuotes();
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
                showSnack(
                  context: context,
                  message:
                      "Couldn't navigate to topic page because topics list is empty",
                  type: SnackType.error,
                );
                return;
              }

              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TopicPage(
                        name: topic.name,
                      )));
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
      final isConnected = userState.isUserConnected;
      final width = MediaQuery.of(context).size.width;

      double horizontal = 10.0;
      double quoteFontSize = 20.0;

      if (width < 390) {
        horizontal = 0.0;
        quoteFontSize = 16.0;
      }

      return SliverList(
        delegate: SliverChildListDelegate.fixed(_topicsList.map((topic) {
          final index = _topicsList.indexOf(topic);
          final color = appTopicsColors.getColorFor(topic.name);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                ),
                child: TopicCardColor(
                  size: 50.0,
                  elevation: 6.0,
                  color: Color(topic.decimal),
                  name: topic.name,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: quotesByTopicsList[index].map((quote) {
                    return QuoteRowWithActions(
                      quote: quote,
                      quoteFontSize: quoteFontSize,
                      color: stateColors.appBackground,
                      isConnected: isConnected,
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
                  }).toList()),
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
          .where('lang', isEqualTo: selectedLang)
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
