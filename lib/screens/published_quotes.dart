import 'package:flutter/material.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/filter_fab.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/small_quote_card.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/add_quote.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/pagination.dart';
import 'package:memorare/types/quote.dart';
import 'package:provider/provider.dart';

class MyPublishedQuotes extends StatefulWidget {
  @override
  MyPublishedQuotesState createState() => MyPublishedQuotesState();
}

class MyPublishedQuotesState extends State<MyPublishedQuotes> {
  String lang = 'en';
  int order = -1;
  List<Quote> quotes = [];

  Pagination pagination = Pagination();
  bool isLoadingMoreQuotes = false;

  int attempts = 1;
  int maxAttempts = 2;

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (quotes.length > 0) { return; }
    fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    if (isLoading) {
      return Scaffold(
        body: LoadingComponent(
          title: 'Loading my published quotes...',
        ),
      );
    }

    if (!isLoading && hasErrors) {
      return ErrorComponent(
        description: error != null ? error.toString() : '',
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Published quotes',
          style: TextStyle(
            color: accent,
            fontSize: 25.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: accent,),
        ),
      ),
      floatingActionButton: quotes.length > 0 ?
        FilterFab(
          onOrderChanged: (int newOrder) {
            setState(() {
              order = newOrder;
            });

            fetchQuotes();
          },
          order: order,
        ):
        Padding(padding: EdgeInsets.zero,),
      body: Builder(
        builder: (BuildContext context) {
          if (quotes.length == 0) {
            return EmptyView(
              title: 'No quotes',
              icon: Icon(Icons.speaker_notes_off, size: 60.0),
              description: 'You have no quotes published yet. Go to the Add Quote page to start sharing your thoughts with others.',
              onRefresh: () async {
                await fetchQuotes();
                return null;
              },
              onTapDescription: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return AddQuote();
                    }
                  )
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await fetchQuotes();
              return null;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollNotif) {
                if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
                  return false;
                }

                if (pagination.hasNext && !isLoadingMoreQuotes) {
                  isLoadingMoreQuotes = true;
                  fetchMoreQuotes();
                }

                return false;
              },
              child: GridView.builder(
                itemCount: quotes.length,
                padding: EdgeInsets.symmetric(vertical: 20.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemBuilder: (BuildContext context, int index) {
                  return SmallQuoteCard(quote: quotes.elementAt(index),);
                },
              ),
            )
          );
        },
      )
    );
  }

  Future fetchQuotes() {
    setState(() {
      isLoading = true;
    });

    pagination = Pagination();

    return Queries.myPublihshedQuotes(
      context: context,
      lang: lang,
      limit: pagination.limit,
      order: order,
      skip: pagination.skip,

    ).then((quotesResp) {
      setState(() {
        isLoading = false;
        quotes = quotesResp.entries;
        pagination = quotesResp.pagination;
      });
    })
    .catchError((err) {
      setState(() {
        isLoading = false;
        hasErrors = true;
        error = err;
      });
    });
  }

  Future fetchMoreQuotes() {
    setState(() {
      isLoadingMoreQuotes = true;
    });

    return Queries.myPublihshedQuotes(
      context: context,
      lang: lang,
      limit: pagination.limit,
      order: order,
      skip: pagination.nextSkip,

    ).then((quotesResp) {
      setState(() {
        isLoadingMoreQuotes = false;
        quotes.addAll(quotesResp.entries);
        pagination = quotesResp.pagination;
      });
    })
    .catchError((err) {
      setState(() {
        isLoadingMoreQuotes = false;
      });
    });
  }
}
