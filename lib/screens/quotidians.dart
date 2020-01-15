import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:memorare/components/add_to_list_button.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/screens/reference_page.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

enum QuoteAction { addList, like, share }

List<Quotidian> _quotidians = [];

class Quotidians extends StatefulWidget {
  @override
  _QuotidiansState createState() => _QuotidiansState();
}

class _QuotidiansState extends State<Quotidians> {
  List<Quotidian> quotidians = [];
  List<String> days = ['today', '2 days ago', 'yesterday'];

  bool isLoading = false;
  bool hasErrors = false;
  bool hasConnection = true;
  Error error;

  bool isStarredFetched = false;

  @override
  initState() {
    super.initState();

    setState(() {
      quotidians = _quotidians;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (quotidians.length > 0) {
      return;
    }

    fetchQuotidians();
  }

  @override
  void dispose() {
    _quotidians = quotidians;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final httpClients = Provider.of<HttpClientsModel>(context, listen: false);

    if (httpClients.authClient != null && !isStarredFetched) {
      fetchWhichStarred();
    }

    if (isLoading) {
      return LoadingComponent(
        backgroundColor: Colors.transparent,
        color: ThemeColor.primary,
        title: 'Loading quotidians...',
      );
    }

    if (!hasConnection) {
      return ErrorComponent(
        description: 'Memorare cannot connect to Internet. Please check your connectivity or contact us if the problem persists.',
        title: 'Quotidians',
        onRefresh: () {
          fetchQuotidians();
        },
      );
    }

    if (hasErrors) {
      return EmptyView(
        title: 'Quotidians',
        description: error != null ?
          error.toString() :
          'An unexpected error ocurred. Please try again.',
        onRefresh: () {
          fetchQuotidians();
        },
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

    return RefreshIndicator(
      onRefresh: () async {
        await fetchQuotidians();
        return null;
      },
      child: ListView(
        children: <Widget>[
          Swiper(
            itemHeight: MediaQuery.of(context).size.height - 80.0,
            itemWidth: MediaQuery.of(context).size.width - 20.0,
            itemCount: quotidians.length,
            layout: SwiperLayout.STACK,
            itemBuilder: (BuildContext context, int index) {
              final quote = quotidians.elementAt(index).quote;

              final orientation = MediaQuery.of(context).orientation;

              return orientation == Orientation.portrait ?
                portraitCard(quote: quote, index: index) :
                landscapeCard(quote: quote, index: index);
            },
          ),
        ],
      ),
    );
  }

  Widget portraitCard({Quote quote, int index}) {
    final topicColor = quote.topics.length > 0 ?
      ThemeColor.topicColor(quote.topics.first) :
      ThemeColor.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 560.0,
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
              icon: Icon(
                Icons.favorite,
                size: 30.0,
              ),
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
              quote.author.name.length < 150 ?
                quote.author.name :
                '${quote.author.name.substring(0, 150)}...',
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
          quote.name.length < 200 ?
          quote.name :
          '${quote.name.substring(0, 200)}...',
          style: TextStyle(
            fontSize: FontSize.bigCard(quote.name),
            fontWeight: FontWeight.bold
          ),
        ),
      )
    );
  }

  Widget reference(Quote quote) {
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
              reference.name.length < 100 ?
                reference.name :
                '${reference.name.substring(0, 100)}...',
              style: TextStyle(
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget landscapeCard({Quote quote, int index}) {
    final topicColor = quote.topics.length > 0 ?
      ThemeColor.topicColor(quote.topics.first) :
      ThemeColor.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 280.0,
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
                child: Stack(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        landscapeContent(quote),
                      ],
                    ),

                    moreButton(context: context, quote: quote),
                    landscapeDay(index),
                  ],
                ),
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget landscapeDay(int index) {
    return Positioned(
      bottom: 10.0,
      left: 30.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Opacity(
          opacity: .6,
          child: Text(
            days.elementAt(index),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget landscapeContent(Quote quote) {
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
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child: Text(
          quote.name.length < 200 ?
          quote.name :
          '${quote.name.substring(0, 200)}...',
          style: TextStyle(
            fontSize: FontSize.landscapeBigCard(quote.name),
            fontWeight: FontWeight.bold
          ),
        ),
      )
    );
  }

  Widget landcapeAuthor(Quote quote) {
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
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              quote.author.name.length < 150 ?
                quote.author.name :
                '${quote.author.name.substring(0, 150)}...',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget moreButton({Quote quote, BuildContext context}) {
    final starred = quote.starred;

    return Positioned(
      bottom: 0,
      right: 0,
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_horiz),
        onSelected: (value) async {
          if (value == 'like') {
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
            return;
          }

          if (value == 'unlike') {
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
            return;
          }

          if (value == 'addTo') {
            return;
          }

          if (value == 'share') {
            return;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: 'addTo',
            child: AddToListButton(
              context: context,
              quoteId: quote.id,
              type: ButtonType.tile,
              onBeforeShowSheet: () => Navigator.pop(context),
            ),
          ),
          PopupMenuItem(
            value: 'share',
            child: ListTile(
              onTap: () {
                Navigator.pop(context);

                final RenderBox box = context.findRenderObject();
                final sharingText = quote.author != null ?
                  '${quote.name} - ${quote.author.name}' :
                  quote.name;

                Share.share(
                  sharingText,
                  subject: 'Memorare quote',
                  sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                );
              },
              leading: Icon(Icons.share),
              title: Text(
                'Share',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          if (!starred)
            const PopupMenuItem(
              value: 'like',
              child: ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text(
                  'Like',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),
          if (starred)
            const PopupMenuItem(
              value: 'unlike',
              child: ListTile(
                leading: Icon(Icons.favorite),
                title: Text(
                  'Unlike',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),
        ],
      ),
    );
  }

  Future fetchQuotidians() async {
    setState(() {
      isLoading = true;
    });

    hasConnection = await DataConnectionChecker().hasConnection;

    if (!hasConnection) {
      setState(() {
        isLoading = false;
      });

      Flushbar(
        backgroundColor: ThemeColor.error,
        message: 'You are offline because Memorare cannot access Internet.',
      )..show(context);

      return;
    }

    return Queries.quotidians(context)
      .then((resp) {
        if (resp == null) {
          return;
        }

        resp.entries.insert(1, resp.entries.removeLast());

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

  Future fetchWhichStarred() async {
    isStarredFetched = true;

    return Queries.quotidians(context)
      .then((resp) {
        resp.entries.insert(1, resp.entries.removeLast());

        if (quotidians.length == 0) { return; }

        for (var i = 0; i < quotidians.length; i++) {
          quotidians.elementAt(i).quote.starred = resp.entries.elementAt(i).quote.starred;
        }

        setState(() {});
      })
      .catchError((err) {});
  }

}
