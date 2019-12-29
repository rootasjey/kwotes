import 'package:flutter/material.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/quotes_by_topics.dart';
import 'package:memorare/types/colors.dart';

List<String> _topicsList = [];

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  List<String> topicsList = [];
  bool isLoading = false;
  bool hasErrors = false;
  String exceptionMessage =  '';

  @override
  void initState() {
    super.initState();
    setState(() {
      topicsList = _topicsList;
    });
  }

  @override
  didChangeDependencies () {
    super.didChangeDependencies();

    if (topicsList.length > 0) { return; }
    fetchTopics();
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
      topicChips.add(topicChip(topic));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await fetchTopics();
        return null;
      },
      child: ListView(
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

          if (!isLoading && hasErrors)
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

          if (isLoading == false && hasErrors == false && topicChips.length > 0)
            Wrap(
              alignment: WrapAlignment.center,
              children: topicChips,
            ),
        ],
      ),
    );
  }

  Widget topicChip(String topic) {
    final chipColor = ThemeColor.topicColor(topic);

    return Padding(
      padding: EdgeInsets.all(5.0),
      child: ActionChip(
        elevation: 2.0,
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: chipColor, width: 3.0)),
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
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Future fetchTopics() {
    setState(() {
      isLoading = true;
      hasErrors = false;
    });

    return Queries.topics(context)
      .then((topicsResp) {
        setState(() {
          topicsList = topicsResp;
          isLoading = false;
        });
      })
      .catchError((err) {
        setState(() {
          hasErrors = true;
          isLoading = false;
        });
      });
  }
 }
