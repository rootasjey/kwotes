import 'package:flutter/material.dart';
import 'package:figstyle/components/topic_card_color.dart';
import 'package:figstyle/screens/topic_page.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/types/topic_color.dart';
import 'package:mobx/mobx.dart';

List<TopicColor> _topics = [];

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  bool isLoading = false;

  ReactionDisposer reactionDisposer;

  @override
  initState() {
    super.initState();

    reactionDisposer = autorun((reaction) {
      if (_topics.length == 0) {
        setState(() {
          _topics = appTopicsColors.shuffle(max: 3);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (reactionDisposer != null) {
      reactionDisposer.reaction.dispose();
    }
  }

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
            child: Divider(
              thickness: 2.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: Opacity(
              opacity: .6,
              child: Text('3 Topics you might like'),
            ),
          ),
          SizedBox(
            width: 400.0,
            height: 200.0,
            child: topicsColorsCards(),
          ),
          allTopicsButton(),
        ],
      ),
    );
  }

  Widget allTopicsButton() {
    return RaisedButton.icon(
      onPressed: () {
        final topicName = appTopicsColors.shuffle(max: 1).first.name;
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TopicPage(name: topicName)));
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(7.0),
        ),
      ),
      color: Colors.black12,
      icon: Opacity(opacity: 0.6, child: Icon(Icons.filter_none)),
      label: Opacity(
        opacity: .6,
        child: Text('Discover more topics'),
      ),
    );
  }

  Widget topicsColorsCards() {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: .8,
      children: _topics.map((topicColor) {
        return TopicCardColor(
          color: Color(topicColor.decimal),
          name:
              '${topicColor.name.substring(0, 1).toUpperCase()}${topicColor.name.substring(1)}',
        );
      }).toList(),
    );
  }
}
