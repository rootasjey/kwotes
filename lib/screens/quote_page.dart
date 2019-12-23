import 'package:flutter/material.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/quotes_by_topics.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';

class QuotePage extends StatefulWidget {
  final String quoteId;

  QuotePage({this.quoteId});

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  Quote quote;
  Color topicColor;

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        if (!isLoading && hasErrors) {
          return ErrorComponent(
            description: error != null ? error.toString() : '',
          );
        }

        if (isLoading) {
          return LoadingComponent(
            title: 'Loading quote...',
            padding: EdgeInsets.all(30.0),
          );
        }

        topicColor = quote.topics.length > 0 ?
          ThemeColor.topicColor(quote.topics.first) :
          ThemeColor.primary;

        return ListView(
          padding: EdgeInsets.only(bottom: 70.0),
          children: <Widget>[
            Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    content(),

                    author(),

                    reference(),

                    topics(),

                    actionButtons(),
                  ],
                ),

                backButton(),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget content() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0,),
      color: topicColor,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Card(
            color: ThemeColor.lighten(topicColor),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 50.0
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    '${quote.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: FontSize.bigCard(quote.name),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget author() {
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${quote.author.name}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget reference() {
    return quote.references.length > 0 ?
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              quote.references.first.name,
              style: TextStyle(),
            ),
          ],
        ),
      ) :
      Padding(padding: EdgeInsets.zero,);
  }

  Widget topics() {
   final topicsDefined = quote.topics != null && quote.topics.length > 0;

    return topicsDefined ?
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Wrap(
          children: quote.topics.map<Widget>((topic) {
            final color = ThemeColor.topicColor(topic);

            return Padding(
              padding: EdgeInsets.all(5.0),
              child: ActionChip(
                shape: StadiumBorder(side: BorderSide(color: color, width: 3.0)),
                backgroundColor: Colors.transparent,
                labelPadding: EdgeInsets.all(5.0),
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
          }).toList(),
        ),
      ) :
      Padding(padding: EdgeInsets.zero,);
  }

  Widget actionButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            padding: EdgeInsets.all(16.0),
            iconSize: 40.0,
            icon: Icon(Icons.favorite_border,),
            onPressed: () {},
          ),
          IconButton(
            padding: EdgeInsets.all(16.0),
            iconSize: 40.0,
            icon: Icon(Icons.playlist_add,),
            onPressed: () {},
          ),
          IconButton(
            padding: EdgeInsets.all(16.0),
            iconSize: 40.0,
            icon: Icon(Icons.share,),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget backButton() {
    return Positioned(
      left: 5.0,
      top: 20.0,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,),
        ),
      )
    );
  }

  void fetchQuote() {
    setState(() {
      isLoading = true;
    });

    Queries.quote(context, widget.quoteId)
      .then((quoteResp) {
        setState(() {
          quote = quoteResp;
          isLoading = false;
          hasErrors = false;
        });
      })
      .catchError((err) {
        setState(() {
          error = err;
          isLoading = false;
          hasErrors = true;
        });
      });
  }
}
