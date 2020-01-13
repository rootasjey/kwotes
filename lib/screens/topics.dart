import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/empty_view.dart';
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
  bool hasConnection = false;
  String exceptionMessage =  '';

  @override
  void initState() {
    super.initState();

    setState(() {
      topicsList = _topicsList;
      isLoading = true;
    });
  }

  @override
  didChangeDependencies () {
    super.didChangeDependencies();

    DataConnectionChecker().hasConnection
      .then((_hasConnection) {
        hasConnection = _hasConnection;

        if (!hasConnection) {
          setState(() {
            isLoading = false;
          });

          return;
        }

        if (topicsList.length > 0) { return; }
        fetchTopics();
      });
  }

  @override
  dispose() {
    _topicsList = topicsList;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading && !hasConnection) {
      return EmptyView(
        title: 'No connection',
        description: 'Memorare cannot reach Internet right now.',
        onRefresh: () {
          DataConnectionChecker().hasConnection
            .then((_hasConnection) {
              if (!hasConnection) { return; }

              fetchTopics();
            });
        },
      );
    }

    if (isLoading) {
      return LoadingComponent();
    }

    if (!isLoading && hasErrors) {
      return EmptyView(
        title: 'Topics',
        description: exceptionMessage.isNotEmpty ?
          exceptionMessage : 'An unexpected error ocurred. Please try again.',
        onRefresh: () {
          fetchTopics();
        },
      );
    }

    List<Widget> topicChips = [];

    for (var topic in topicsList) {
      topicChips.add(topicChip(topic));
    }

    if (topicChips.length == 0) {
      return EmptyView(
        title: 'Topics',
        description: 'Sorry, no topic could be retrieved for now.',
        onRefresh: () {
          fetchTopics();
        },
      );
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

  Future fetchTopics() async {
    setState(() {
      isLoading = true;
      hasErrors = false;
    });

    hasConnection = await DataConnectionChecker().hasConnection;

    if (!hasConnection) {
      setState(() {
        isLoading = false;
        hasErrors = true;
      });

      return;
    }

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
