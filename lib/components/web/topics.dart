import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/topic_color.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

List<TopicColor> _topics = [];

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 90.0,
        horizontal: 80.0,
      ),
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Text(
              'TOPICS',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),

          SizedBox(
            width: 50.0,
            child: Divider(thickness: 2.0,),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                '3 Topics you might like'
              ),
            ),
          ),

          SizedBox(
            width: 400.0,
            height: 200.0,
            child: topicsColorsCards(),
          ),

          RaisedButton(
            onPressed: () {
              FluroRouter.router.navigateTo(
                context,
                TopicRoute.replaceFirst(
                  ':name',
                  appTopicsColors.shuffle(max: 1).first.name,
                ),
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(7.0),
              ),
            ),
            color: Colors.black12,
            child: Opacity(
              opacity: .6,
              child: Text(
                'Discover more topics'
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topicsColorsCards() {
    int count = 0;

    return Observer(
      builder: (context) {
        if (_topics.length == 0) {
          _topics = appTopicsColors.shuffle(max: 3);
        }

        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: .8,
          children: _topics.map((topicColor) {
            count++;

            return FadeInY(
              beginY: 50.0,
              endY: 0.0,
              delay: count.toDouble(),
              child: TopicCardColor(
                color: Color(topicColor.decimal),
                name: '${topicColor.name.substring(0, 1).toUpperCase()}${topicColor.name.substring(1)}',
              ),
            );

          }).toList(),
        );
      },
    );
  }
}
