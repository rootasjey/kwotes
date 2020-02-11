import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/topic_color.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class TopicPage extends StatefulWidget {
  final String name;

  TopicPage({
    this.name,
  });

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  int decimal = 4283980123;
  bool isLoading = false;
  List<Quote> quotes = [];
  TopicColor topicColor;

  @override
  void initState() {
    super.initState();

    fetchTopic();
    fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 50.0, bottom: 100.0),
          child: Stack(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TopicCardColor(
                    color: Color(decimal),
                    name: widget.name,
                  ),
                ],
              ),

              Positioned(
                left: 80.0,
                top: 30.0,
                child: IconButton(
                  onPressed: () {
                    FluroRouter.router.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
            ],
          ),
        ),

        gridQuotes(),

        NavBackFooter(),
      ],
    );
  }

  Widget gridQuotes() {
    final children = <Widget>[];

    quotes.forEach((quote) {
      children.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: 250.0,
            height: 250.0,
            child: Card(
              shape: BorderDirectional(
                bottom: BorderSide(
                  color: Color(decimal),
                  width: 2.0,
                ),
              ),
              child: InkWell(
                onTap: () {
                  FluroRouter.router.navigateTo(
                    context,
                    QuotePageRoute.replaceFirst(':id', quote.id)
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        quote.name,
                        style: TextStyle(
                          fontSize: adaptativeFont(quote.name),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      );
    });

    return Wrap(
      children: children,
    );
  }

  void fetchTopic() async {
    try {
      final doc = await FirestoreApp.instance
        .collection('topics')
        .doc(widget.name)
        .get();

      if (!doc.exists) { return; }

      topicColor = TopicColor.fromJSON(doc.data());
      decimal = topicColor.decimal;

    } catch (error) {
    }
  }

  void fetchQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('quotes')
        .where('topics.${widget.name}', '==', true)
        .where('lang', '==', 'en')
        .limit(10)
        .get();

      if (snapshot.empty) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      snapshot.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        isLoading = false;
      });

    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  double adaptativeFont(String text) {
    if (text.length > 90) {
      return 16.0;
    }

    if (text.length > 60) {
      return 18.0;
    }

    return 20.0;
  }
}
