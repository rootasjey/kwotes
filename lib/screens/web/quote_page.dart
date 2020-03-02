import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/topic_color.dart';
import 'package:memorare/utils/router.dart';

class QuotePage extends StatefulWidget {
  final String quoteId;

  QuotePage({this.quoteId});

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  bool isLoading;
  Quote quote;
  List<TopicColor> topicColors = [];

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: <Widget>[
          Text('Loading...')
        ],
      );
    }

    if (quote == null) {
      return Text('Error while loading the quote.');
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height - 0.0,
          child: Padding(
            padding: EdgeInsets.all(70.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          FluroRouter.router.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                      )
                    ],
                  ),
                ),

                Text(
                  quote.name,
                  style: TextStyle(
                    fontSize: FontSize.hero(quote.name),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: SizedBox(
                    width: 200.0,
                    child: Divider(
                      color: Color(0xFF64C7FF),
                      thickness: 2.0,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Opacity(
                    opacity: .8,
                    child: Text(
                      quote.author.name,
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  )
                ),

                if (quote.mainReference?.name != null &&
                  quote.mainReference.name.length > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Opacity(
                      opacity: .6,
                      child: Text(
                        quote.mainReference.name,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () { print('fav'); },
                icon: Icon(Icons.favorite_border),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: IconButton(
                  onPressed: () { print('share'); },
                  icon: Icon(Icons.share),
                ),
              ),

              IconButton(
                onPressed: () { print('add list'); },
                icon: Icon(Icons.playlist_add),
              ),
            ],
          ),
        ),

        topicsList(),

        NavBackFooter(),
      ],
    );
  }

  Widget topicsList() {
    if (topicColors.length == 0) {
      return Padding(padding: EdgeInsets.zero);
    }

    final children = <Widget>[];

    topicColors.forEach((topic) {
      children.add(
        TopicCardColor(
          color: Color(topic.decimal),
          name: topic.name,
        )
      );
    });

    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color(0xFFF2F2F2),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 300,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 80.0,),
              scrollDirection: Axis.horizontal,
              children: children,
            ),
          ),

        ],
      ),
    );
  }

  void fetchTopics() async {
    final _topicsColors = <TopicColor>[];

    for (String topicName in quote.topics) {
      final doc = await FirestoreApp.instance
        .collection('topics')
        .doc(topicName)
        .get();

      if (doc.exists) {
        final topic = TopicColor.fromJSON(doc.data());
        _topicsColors.add(topic);
      }
    }

    setState(() {
      topicColors = _topicsColors;
    });
  }

  void fetchQuote() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await FirestoreApp.instance
        .collection('quotes')
        .doc(widget.quoteId)
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

      return;
      }

      setState(() {
        isLoading = false;
        quote = Quote.fromJSON(doc.data());
      });

      fetchTopics();

    } catch (error) {
      setState(() {
        isLoading = false;
      });

      print(error);
    }
  }
}
