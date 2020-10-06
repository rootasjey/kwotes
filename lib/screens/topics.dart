import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/topic_color.dart';
import 'package:supercharged/supercharged.dart';

List<TopicColor> _topicsList = [];

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  final limit = 4;
  bool ignoreCount = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          ignoreCount = true;
          _topicsList.clear();
        });

        Future.delayed(50.milliseconds, () {
          setState(() {
            ignoreCount = false;
          });
        });

        return null;
      },
      child: ListView(
        padding: const EdgeInsets.only(
          top: 50.0,
          bottom: 200.0,
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0),
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
          Divider(
            height: 60.0,
          ),
          topicsColorsCards(),
          FadeInY(
            delay: 5.0,
            beginY: 100.0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => Topics()));
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: stateColors.primary),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: Opacity(
                    opacity: .6,
                    child: Text('Discover more topics'),
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
        if (_topicsList.length == 0 && !ignoreCount) {
          _topicsList = appTopicsColors.shuffle(max: limit);
        }

        return Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: _topicsList.map((topicColor) {
            count++;

            String name = topicColor.name;
            String displayName =
                '${name.substring(0, 1).toUpperCase()}${name.substring(1)}';

            if (displayName.length > 9) {
              displayName = '${displayName.substring(0, 8)}...';
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
                displayName: displayName,
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
