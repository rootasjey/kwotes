import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/screens/quotes_by_topics.dart';
import 'package:memorare/types/colors.dart';

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: queryTopics(),
      ),
      builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
        if (result.hasErrors) {
          return ErrorComponent(
            description: result.errors.first.message,
            title: 'topics',
          );
        }

        if (result.loading) {
          return LoadingComponent(
            title: 'Loading topics...',
            padding: EdgeInsets.all(30.0),
          );
        }

        List<Widget> topicChips = [];

        Map<String, dynamic> json = result.data;
        for (var topic in json['randomTopics']) {
          final chipColor = ThemeColor.topicColor(topic);

          topicChips.add(
            Padding(
              padding: EdgeInsets.all(5.0),
              child: ActionChip(
                backgroundColor: chipColor,
                labelPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return QuotesByTopics(topic: topic,);
                      }
                    )
                  );
                },
                label: Text(
                  topic,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          );
        }

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.all(20.0),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'Topics',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40.0),
                ),
              ),

              Wrap(
                alignment: WrapAlignment.center,
                children: topicChips,
              ),
            ],
          ),
        );
      },
    );
  }

  String queryTopics() {
    return """
      query {
        randomTopics
      }
    """;
  }
}
