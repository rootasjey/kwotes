import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:provider/provider.dart';

enum QuoteAction { addList, like, share }

class Quotidians extends StatefulWidget {
  @override
  _QuotidiansState createState() => _QuotidiansState();
}

class _QuotidiansState extends State<Quotidians> {
  Quotidian quotidian;
  bool isLoading = false;
  bool hasErrors = false;
  NoSuchMethodError error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchQuotidian();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Provider.of<ThemeColor>(context).background;

    if (isLoading) {
      return LoadingComponent(
        backgroundColor: Colors.transparent,
        color: backgroundColor,
        title: 'Loading quotidians',
      );
    }

    if (hasErrors) {
      if (error.toString().contains('No host specified in URI')) {
        print('rrrr');
      }

      return ErrorComponent(
        description: error != null ? error.toString() : '',
        title: 'Quotidians',
      );
    }

    final quote = quotidian.quote;

    final topicColor = quote.topics.length > 0 ?
      ThemeColor.topicColor(quote.topics.first) :
      ThemeColor.primary;

    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(25.0),
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: BorderSide(
                color: topicColor,
                width: 5.0,
              ),
            ),
            child: Column(
              children: <Widget>[
                content(quote),

                author(quote),

                if (quote.references.length > 0)
                  reference(quote),

                actionIcons(quote),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget actionIcons(Quote quote) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.playlist_add,
              size: 30.0,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              size: 30.0,
            ),
            onPressed: () {},
          ),

          if (!quote.starred)
            IconButton(
              icon: Icon(
                Icons.favorite_border,
                size: 30.0,
              ),
              onPressed: () async {
                setState(() { // optimistic
                  quote.starred = true;
                });

                final booleanMessage = await UserMutations.star(context, quote.id);

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
              icon: Icon(
                Icons.favorite,
                size: 30.0,
              ),
              onPressed: () async {
                setState(() { // optimistic
                  quote.starred = false;
                });

                final booleanMessage = await UserMutations.unstar(context, quote.id);

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

  Widget author(Quote quote) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return AuthorPage(
                authorId: quote.author.id,
                authorName: quote.author.name,
              );
            }
          )
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
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
      ),
    );
  }

  Widget content(Quote quote) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return QuotePage(quoteId: quote.id,);
            }
          )
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: Text(
          '${quote.name}',
          style: TextStyle(
            fontSize: FontSize.bigCard(quote.name),
            fontWeight: FontWeight.bold
          ),
        ),
      )
    );
  }

  Widget reference(Quote quote) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            quote.references.first.name,
            style: TextStyle(
            ),
          ),
        ],
      ),
    );
  }

  void fetchQuotidian() {
    setState(() {
      isLoading = true;
    });

    Queries.quotidian(context)
      .then((quotidianResponse) {
        // http client not ready
        if (quotidianResponse == null) {
          return;
        }

        setState(() {
          quotidian = quotidianResponse;
          isLoading = false;
        });
      })
      .catchError((err) {
        setState(() {
          error = err;
          hasErrors = true;
          isLoading = false;
        });
      });

      // if (exception.clientException
      //   .message.contains('No host specified in URI')) {

      //   return LoadingComponent(
      //     title: 'Loading quotidians',
      //     padding: EdgeInsets.all(30.0),
      //   );
      // }
  }
}
