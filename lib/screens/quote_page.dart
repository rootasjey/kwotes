import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/add_to_list_button.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/quotes_by_topics.dart';
import 'package:memorare/screens/reference_page.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:share/share.dart';

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
    if (quote != null) { return; }
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

                    Padding(padding: EdgeInsets.only(top: 40.0),),

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
    final author = quote.author;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return AuthorPage(
                id: author.id,
                authorName: author.name,
              );
            }
          )
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${author.name}',
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
    if (quote.references == null || quote.references.length == 0) {
      return Padding(padding: EdgeInsets.zero,);
    }

    final reference = quote.references.first;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ReferencePage(
                id: reference.id,
                referenceName: reference.name,
              );
            }
          )
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              reference.name,
              style: TextStyle(),
            ),
          ],
        ),
      ),
    );
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
            padding: EdgeInsets.all(30.0),
            iconSize: 40.0,
            icon: Icon(Icons.share,),
            onPressed: () {
              final RenderBox box = context.findRenderObject();
              final sharingText = '${quote.name} - ${quote.author.name}';

              Share.share(
                sharingText,
                subject: 'Memorare quote',
                sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
              );
            },
          ),

          AddToListButton(
            context: context,
            quoteId: quote.id,
            size: 40.0,
          ),

          if (!quote.starred)
            IconButton(
              padding: EdgeInsets.all(30.0),
              iconSize: 40.0,
              icon: Icon(Icons.favorite_border,),
              onPressed: () async {
                setState(() { // optimistic
                  quote.starred = true;
                });

                final booleanMessage = await Mutations.star(context, quote.id);

                if (!booleanMessage.boolean) {
                  setState(() { // rollback
                    quote.starred = false;
                  });

                  Flushbar(
                    duration: Duration(seconds: 2),
                    backgroundColor: ThemeColor.error,
                    message: booleanMessage.message,
                  )..show(context);
                }
              },
            ),

          if (quote.starred)
            IconButton(
              padding: EdgeInsets.all(30.0),
              iconSize: 40.0,
              icon: Icon(Icons.favorite,),
              onPressed: () async {
                setState(() { // optimistic
                  quote.starred = false;
                });

                final booleanMessage = await Mutations.unstar(context, quote.id);

                if (!booleanMessage.boolean) {
                  setState(() { // rollback
                    quote.starred = true;
                  });

                  Flushbar(
                    duration: Duration(seconds: 2),
                    backgroundColor: ThemeColor.error,
                    message: booleanMessage.message,
                  )..show(context);
                }
              },
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
