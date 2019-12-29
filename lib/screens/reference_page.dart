import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/button_link.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:provider/provider.dart';

class ReferencePage extends StatefulWidget {
  final String id;
  final String referenceName;

  ReferencePage({this.id, this.referenceName});

  @override
  ReferencePageState createState() => ReferencePageState();
}

class ReferencePageState extends State<ReferencePage> {
  Reference reference;
  List<Quote> quotes = [];
  bool areQuotesLoading = false;
  bool areQuotesLoaded = false;

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchReference();
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
            title: 'Loading ${widget.referenceName}...',
            padding: EdgeInsets.all(30.0),
          );
        }

        final themeColor = Provider.of<ThemeColor>(context);

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollNotif) {
            if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
              return false;
            }

            if (!areQuotesLoading && !areQuotesLoaded) {
              if (quotes.length > 0) { return false; }

              areQuotesLoading = true;

              Queries.quotesByReference(context, widget.id)
                .then((quotesResp) {
                  setState(() {
                    quotes = quotesResp.entries;
                    areQuotesLoading = false;
                    areQuotesLoaded = true;
                  });
                })
                .catchError((err) {
                  setState(() {
                    error = err;
                    areQuotesLoading = false;
                    areQuotesLoaded = true;
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
                        picture(),

                        name(),

                        type(themeColor.background),

                        summary(),

                        buttonsLinks(),

                        if (areQuotesLoading)
                          Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: LinearProgressIndicator(),
                          ),

                        Divider(),

                        referenceQuotes(),
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

  Widget picture() {
    return Padding(
      padding: EdgeInsets.only(top: 70.0),
      child: InkWell(
        onTap: () {
          if (reference.imgUrl == null || reference.imgUrl.length == 0) {
            return;
          }

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  child: Image(image: NetworkImage(reference.imgUrl),),
                ),
              );
            }
          );
        },
        child: reference.imgUrl != null && reference.imgUrl.length > 0 ?
          SizedBox(
            width: 200,
            height: 200,
            child: Card(
              elevation: 5.0,
              color: ThemeColor.primary,
              child: Image.network(
                reference.imgUrl,
                fit: BoxFit.cover,
              )
            ),
          ):
          SizedBox(
            width: 200,
            height: 200,
            child: Card(
              elevation: 5.0,
              child: Center(
                child: Text(
                  reference.name.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    fontSize: 50.0,
                  ),
                ),
              )
            ),
          ),
      )
    );
  }

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Text(
        reference.name,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget type(Color color) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Text(
        reference.type,
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
    final padding = reference.summary != null && reference.summary.length > 0 ?
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0):
      EdgeInsets.zero;

    return Padding(
      padding: padding,
      child: Text(
        reference.summary,
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
    final wikiUrlDefined = reference.wikiUrl != null && reference.wikiUrl.length > 0;
    final urlDefined = reference.wikiUrl != null && reference.wikiUrl.length > 0;

    return Column(
      children: <Widget>[
        if (wikiUrlDefined)
          ButtonLink(
            icon: Icon(IconsMore.wikipedia_w, color: Colors.white,),
            padding: EdgeInsets.only(top: 10.0),
            text: 'Open Wikipedia',
            url: reference.wikiUrl,
          ),

        if (urlDefined)
          ButtonLink(
            icon: Icon(IconsMore.earth, color: Colors.white),
            padding: EdgeInsets.only(top: 10.0),
            text: 'Open website',
            url: reference.wikiUrl,
          ),
      ],
    );
  }

  Widget referenceQuotes() {
    return quotes.length > 0 ?
      Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: SizedBox(
          height: 330.0,
          child: Swiper(
            itemCount: quotes.length,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: MediumQuoteCard(
                  quote: quotes.elementAt(index),
                  onLike: () async {
                    setState(() { // optimistic
                      quotes.elementAt(index).starred = true;
                    });

                    final booleanMessage = await UserMutations.star(
                      context,
                      quotes.elementAt(index).id
                    );

                    if (!booleanMessage.boolean) {
                      setState(() { // rollback
                        quotes.elementAt(index).starred = false;
                      });

                      Flushbar(
                        duration: Duration(seconds: 2),
                        backgroundColor: ThemeColor.error,
                        message: booleanMessage.message,
                      )..show(context);
                    }
                    },
                  onUnlike: () async {
                    setState(() { // optimistic
                      quotes.elementAt(index).starred = false;
                    });

                    final booleanMessage = await UserMutations.unstar(
                      context,
                      quotes.elementAt(index).id
                    );

                    if (!booleanMessage.boolean) {
                      setState(() { // rollback
                        quotes.elementAt(index).starred = true;
                      });

                      Flushbar(
                        duration: Duration(seconds: 2),
                        backgroundColor: ThemeColor.error,
                        message: booleanMessage.message,
                      )..show(context);
                    }
                  },
                ),
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

  void fetchReference() {
    setState(() {
      isLoading = true;
    });

    Queries.reference(context, widget.id)
      .then((referenceResp) {
        setState(() {
          reference = referenceResp;
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
