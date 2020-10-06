import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class AllTopics extends StatefulWidget {
  @override
  _AllTopicsState createState() => _AllTopicsState();
}

class _AllTopicsState extends State<AllTopics> {
  final _scrollController = ScrollController();
  bool isFabVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: body(),
    );
  }

  Widget body() {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            bodyContent(),
            NavBackFooter(),
          ],
        ),
        Footer(),
      ],
    );
  }

  Widget bodyContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              snap: true,
              expandedHeight: 340.0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          AppIconHeader(),
                          FadeInY(
                            beginY: 50.0,
                            child: Text(
                              'TOPICS',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          ControlledAnimation(
                            delay: 1.seconds,
                            duration: 1.seconds,
                            tween: Tween(begin: 0.0, end: 50.0),
                            builder: (context, value) {
                              return SizedBox(
                                width: value,
                                child: Divider(
                                  thickness: 2.0,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    left: 80.0,
                    top: 80.0,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      tooltip: 'Back',
                      icon: Icon(Icons.arrow_back),
                    ),
                  ),
                ],
              ),
            ),
            topicsColorsCards(),
          ],
        ),
      ),
    );
  }

  Widget topicsColorsCards() {
    return Observer(
      builder: (context) {
        if (appTopicsColors.topicsColors.length == 0) {
          return SliverList(
            delegate: SliverChildListDelegate([
              LoadingAnimation(
                textTitle: 'Loading topics...',
              ),
            ]),
          );
        }

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final topicColor = appTopicsColors.topicsColors.elementAt(index);

              return FadeInY(
                beginY: 50.0,
                endY: 0.0,
                delay: index.toDouble(),
                child: TopicCardColor(
                  color: Color(topicColor.decimal),
                  name: topicColor.name,
                ),
              );
            },
            childCount: appTopicsColors.topicsColors.length,
          ),
        );
      },
    );
  }
}
