import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/button_link.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:provider/provider.dart';

class AuthorPage extends StatefulWidget {
  final String id;
  final String authorName;
  AuthorPage({this.id, this.authorName});

  @override
  _AuthorPageState createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  Author author;
  List<Quote> quotes = [];
  bool areQuotesLoading = false;
  bool hasQuotesErrors = false;

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchAuthor();
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
            title: 'Loading ${widget.authorName}...',
            padding: EdgeInsets.all(30.0),
          );
        }

        final themeColor = Provider.of<ThemeColor>(context);

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollNotif) {
            if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
              return false;
            }

            if (!areQuotesLoading && !hasQuotesErrors) {
              if (quotes.length > 0) { return false; }

              setState(() {
                areQuotesLoading = true;
              });

              Queries.quotesByAuthor(context, widget.id)
                .then((quotesResp) {
                  setState(() {
                    quotes = quotesResp.entries;
                    areQuotesLoading = false;
                  });
                })
                .catchError((err) {
                  setState(() {
                    error = err;
                    areQuotesLoading = false;
                    hasQuotesErrors = true;
                  });
                });
            }

            return false;
          },
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    alignment: AlignmentDirectional.center,
                    child: Column(
                      children: <Widget>[
                        avatar(),

                        name(),

                        job(themeColor.background),

                        summary(),

                        buttonsLinks(),

                        Padding(padding: EdgeInsets.only(top: 40.0),),

                        if (areQuotesLoading)
                          LinearProgressIndicator(),

                        Divider(),

                        authorQuotes(),
                      ],
                    ),
                  ),

                  backButton(),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget avatar() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: InkWell(
        onTap: () {
          if (author.imgUrl == null) { return; }

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  child: Image(image: NetworkImage(author.imgUrl),),
                ),
              );
            }
          );
        },
        child: CircleAvatar(
          radius: 90.0,
          backgroundColor: ThemeColor.primary,
          backgroundImage: author.imgUrl != null ?
            NetworkImage(author.imgUrl) :
            AssetImage('assets/images/monk.png'),
        ),
      )
    );
  }

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Text(
        author.name,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget job(Color color) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Text(
        author.job,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget summary() {
    return Padding(
      padding: EdgeInsets.only(top: 60.0),
      child: Text(
        author.summary,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w100,
          height: 1.5,
        ),
      ),
    );
  }

  Widget buttonsLinks() {
    final wikiUrlDefined = author.wikiUrl != null && author.wikiUrl.length > 0;
    final urlDefined = author.url != null && author.url.length > 0;

    return Column(
      children: <Widget>[
        if (wikiUrlDefined || urlDefined)
          Padding(padding: EdgeInsets.only(top: 50),),

        if (wikiUrlDefined)
          ButtonLink(
            icon: Icon(IconsMore.wikipedia_w, color: Colors.white,),
            padding: EdgeInsets.only(top: 10.0),
            text: 'Open Wikipedia',
            url: author.wikiUrl,
          ),

        if (urlDefined)
          ButtonLink(
            icon: Icon(IconsMore.earth, color: Colors.white),
            padding: EdgeInsets.only(top: 10.0),
            text: 'Open website',
            url: author.url,
          ),
      ],
    );
  }

  Widget authorQuotes() {
    return quotes.length > 0 ?
      Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: SizedBox(
          height: 330.0,
          child: Swiper(
            itemCount: quotes.length,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: MediumQuoteCard(quote: quotes.elementAt(index),),
              );
            },
          ),
        ),
      ) :
      Padding(padding: EdgeInsets.zero);
  }

  Widget backButton() {
    return Positioned(
      left: 0.0,
      top: 0.0,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
      )
    );
  }

  void fetchAuthor() {
    setState(() {
      isLoading = true;
    });

    Queries.author(context, widget.id)
      .then((authorResp) {
        setState(() {
          author = authorResp;
          hasErrors = false;
          isLoading = false;
        });
      })
      .catchError((err) {
        setState(() {
          error = err;
          hasErrors = false;
          isLoading = false;
        });
      });
  }
}
