import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/topic_color.dart';

List<TopicColor> _topicsList = [];

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (_topicsList.length > 0) { return; }
    fetchTopics();
  }

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
            width: 360.0,
            child: Wrap(
              children: topicsColorsCards(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> topicsColorsCards() {
    List<Widget> cards = [];
    int count = 0;

    _topicsList.forEach((topicColor) {
      cards.add(
        TopicCardColor(
          color: count < 3 ?
            Color(topicColor.decimal) :
            ThemeColor.topicColor('work'),
          name: topicColor.name,
        ),
      );

      count++;
    });

    return cards;
  }

  void fetchTopics() async {
    setState(() {
      isLoading = true;
    });

    final random = Random();

    try {
      final snapshot = await FirestoreApp.instance
        .collection('topics')
        .where('random', '>=', random.nextInt(100000000))
        .limit(6)
        .get();

      if (snapshot.empty) {
        setState(() {
          isLoading = false;
          return;
        });
      }

      snapshot.forEach((doc) {
        _topicsList.add(TopicColor.fromJSON(doc.data()));
      });

      setState(() {});

    } catch (error) {
      setState(() {
        isLoading = false;
      });

      debugPrint(error.toString());
    }
  }
}
