import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/topic_color.dart';

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  bool isLoading = false;
  List<TopicColor> topicsColorsList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F2F2),
      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 80.0),
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
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'Choose a topic you would like to explore.'
              ),
            ),
          ),

          SizedBox(
            width: 330.0,
            child: Wrap(
              children: <Widget>[
                TopicCardColor(
                  color: ThemeColor.topicColor('art'),
                  name: 'art',
                ),

                TopicCardColor(
                  color: ThemeColor.topicColor('feelings'),
                  name: 'feelings',
                ),

                TopicCardColor(
                  color: ThemeColor.topicColor('fun'),
                  name: 'fun',
                ),

                TopicCardColor(
                  color: ThemeColor.topicColor('work'),
                  name: 'language',
                ),

                TopicCardColor(
                  color: ThemeColor.topicColor('work'),
                  name: 'knowledge',
                ),

                TopicCardColor(
                  color: ThemeColor.topicColor('work'),
                  name: 'metaphor',
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        print('empty');
        setState(() {
          isLoading = false;
          return;
        });
      }

      snapshot.forEach((doc) {
        print('doc => ${doc.data()}');
        topicsColorsList.add(TopicColor.fromJSON(doc.data()));
      });

      setState(() {});

    } catch (error) {
      setState(() {
        isLoading = false;
      });

      debugPrint(error);
    }
  }
}
