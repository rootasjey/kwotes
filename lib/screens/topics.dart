import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/queriesOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/screens/quotes_by_topics.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

List<String> _topicsList = [];

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  List<String> topicsList = [];
  bool isLoading = false;
  bool hasExceptions = false;
  String exceptionMessage =  '';

  @override
  didChangeDependencies () {
    super.didChangeDependencies();

    setState(() {
      isLoading = true;
    });

    if (_topicsList.length > 0) {
      setState(() {
        topicsList = _topicsList;
        isLoading = false;
      });

    } else {
      fetchTopics()
        .then((topics) {
          setState(() {
            topicsList = topics;
            isLoading = false;
          });
        });
    }
  }

  @override
  dispose() {
    _topicsList = topicsList;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> topicChips = [];

    for (var topic in topicsList) {
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

          if (isLoading)
            LoadingComponent(),

          if (!isLoading && hasExceptions)
            ErrorComponent(description: exceptionMessage, title: 'Topics',),

          if (topicChips.length == 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Sorry, no topic could be retrieved for now.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.0),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });

                        fetchTopics()
                          .then((topics) {
                            setState(() {
                              topicsList = topics;
                              isLoading = false;
                            });
                          });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          'Try again',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

          if (isLoading == false && hasExceptions == false && topicChips.length > 0)
            Wrap(
              alignment: WrapAlignment.center,
              children: topicChips,
            ),
        ],
      ),
    );
  }

  Future<List<String>> fetchTopics() {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.query(
      QueryOptions(
        documentNode: QueriesOperations.topics,
      )
    )
    .then((queryResult) {
      List<String> topics = [];

      if (queryResult.hasException) {
        hasExceptions = true;

        exceptionMessage = queryResult.exception.graphqlErrors.length > 0 ?
          queryResult.exception.graphqlErrors.first.message :
          queryResult.exception.clientException.message;

        return topics;
      }

      final json = queryResult.data;

      for (var str in json['randomTopics']) {
        topics.add(str);
      }

      return topics;
    })
    .catchError((error) {
      hasExceptions = true;
      exceptionMessage = error.toString();
      return List<String>();
    });
  }
 }
