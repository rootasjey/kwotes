import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/router/router.dart';
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
      floatingActionButton: isFabVisible ?
        FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0.0,
              duration: Duration(seconds: 1),
              curve: Curves.easeOut,
            );
          },
          backgroundColor: stateColors.primary,
          child: Icon(Icons.arrow_upward),
        ) : null,
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
            Observer(
              builder: (_) {
                return SliverAppBar(
                  floating: true,
                  snap: true,
                  expandedHeight: 100.0,
                  backgroundColor: stateColors.softBackground,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Stack(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              FadeInY(
                                beginY: 50.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    'TOPICS',
                                    style: TextStyle(
                                      fontSize: 25.0,
                                    ),
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
                                    child: Divider(thickness: 2.0,),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      Positioned(
                        left: 20.0,
                        top: 20.0,
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
                );
              },
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
            delegate: SliverChildListDelegate(
              [
                LoadingAnimation(
                  title: 'Loading topics...',
                ),
              ]
            ),
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
                  size: 100.0,
                  color: Color(topicColor.decimal),
                  name: topicColor.name,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
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
