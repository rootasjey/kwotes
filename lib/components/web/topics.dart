import 'package:flutter/material.dart';
import 'package:memorare/components/web/topic_card_color.dart';

class Topics extends StatelessWidget {
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
                'Choose a topic you like to explorer related quotes.'
              ),
            ),
          ),

          Wrap(
            children: <Widget>[
              TopicCardColor(
                color: Colors.blue,
                name: 'art',
              ),

              TopicCardColor(
                color: Colors.red,
                name: 'feelings',
              ),

              TopicCardColor(
                color: Color(0xFFFFC11E),
                name: 'fun',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
