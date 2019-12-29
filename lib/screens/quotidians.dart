import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:memorare/components/add_to_list_button.dart';
import 'package:memorare/components/empty_view.dart';
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
  List<Quotidian> quotidians = [];
  List<String> days = ['today', 'yesterday', '2 days ago'];

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (quotidians.length > 0) { return; }
    fetchQuotidians();
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
      return ErrorComponent(
        description: error != null ? error.toString() : '',
        title: 'Quotidians',
      );
    }

    if (quotidians.length == 0) {
      return Column(
        children: <Widget>[
          EmptyView(
            title: 'Quotidians',
            description: 'It is odd. There is no quotidians for today 🤔. ',
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Try again'
              ),
            ),
          ),
        ],
      );
    }

    return Swiper(
      itemWidth: MediaQuery.of(context).size.width - 20.0,
      itemCount: quotidians.length,
      layout: SwiperLayout.STACK,
      itemBuilder: (BuildContext context, int index) {
        final quote = quotidians.elementAt(index).quote;

        final topicColor = quote.topics.length > 0 ?
          ThemeColor.topicColor(quote.topics.first) :
          ThemeColor.primary;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 550.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: BorderSide(
                        color: topicColor,
                        width: 5.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        content(quote),

                        author(quote),

                        if (quote.references.length > 0)
                          reference(quote),

                        actionIcons(quote),
                      ],
                    ),
                  ),
                )
              ),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Opacity(
                  opacity: .6,
                  child: Text(
                    days.elementAt(index),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget actionIcons(Quote quote) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          AddToListButton(quoteId: quote.id,),
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
                id: quote.author.id,
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

  void fetchQuotidians() {
    setState(() {
      isLoading = true;
    });

    Queries.quotidians(context)
    .then((resp) {
      if (resp == null) {
        return;
      }

      setState(() {
        hasErrors = false;
        quotidians = resp.entries;
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
  }
}
