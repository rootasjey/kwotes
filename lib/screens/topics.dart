import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/topic_color.dart';

List<TopicColor> _topicsList = [];

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  final limit = 4;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _topicsList.clear();
        _topicsList = appTopicsColors.shuffle(max: limit);
        return null;
      },
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: Text(
              'Topics',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                '$limit Topics you might like',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),

          Divider(height: 60.0,),

          topicsColorsCards(),

          FadeInY(
            delay: 5.0,
            beginY: 100.0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: FlatButton(
                  onPressed: () {
                    FluroRouter.router.navigateTo(context, TopicsRoute);
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: stateColors.primary),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: Opacity(
                    opacity: .6,
                    child: Text(
                      'Discover more topics'
                    ),
                  ),
                ),
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
        if (_topicsList.length == 0) {
          _topicsList = appTopicsColors.shuffle(max: limit);
        }

        return Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: _topicsList.map((topicColor) {
            count++;

            String name = '${topicColor.name.substring(0, 1).toUpperCase()}${topicColor.name.substring(1)}';

            if (name.length > 9) {
              name = '${name.substring(0, 8)}...';
            }

            return FadeInY(
              beginY: 100.0,
              endY: 0.0,
              delay: count.toDouble(),
              child: TopicCardColor(
                size: 100.0,
                elevation: 6.0,
                color: Color(topicColor.decimal),
                name: name,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
 }
