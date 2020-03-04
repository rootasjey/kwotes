import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/topic_color.dart';

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
      color: Color(0xFFF2F2F2),
      padding: EdgeInsets.symmetric(vertical: 90.0, horizontal: 80.0),
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
                'Choose a topic you would like to explore.'
              ),
            ),
          ),

          SizedBox(
            width: 400.0,
            height: 400.0,
            child: topicsColorsCards(),
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
          _topics = appTopicsColors.shuffle(max: 6);
        }

        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: .8,
          children: _topics.map((topicColor) {
            count++;

            return TopicCardColor(
              color: count < 4 ?
                Color(topicColor.decimal) :
                Color(0xFF58595B),
              name: topicColor.name,
            );

          }).toList(),
        );
      },
    );
  }
}
