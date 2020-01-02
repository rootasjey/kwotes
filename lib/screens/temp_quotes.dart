import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/filter_fab.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/small_temp_quote_card.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/add_quote.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/pagination.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:provider/provider.dart';

class MyTempQuotes extends StatefulWidget {
  @override
  MyTempQuotesState createState() => MyTempQuotesState();
}

class MyTempQuotesState extends State<MyTempQuotes> {
  String lang = 'en';
  int order = -1;
  List<TempQuote> quotes = [];

  Pagination pagination = Pagination();
  bool isLoadingMoreQuotes = false;
  ScrollController gridViewScrollController = ScrollController();

  int attempts = 1;
  int maxAttempts = 2;

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchTempQuotes();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeColor>(context);
    final accent = themeColor.accent;
    final backgroundColor = themeColor.background;

    if (isLoading) {
      return Scaffold(
        body: LoadingComponent(
          title: 'Loading my quotes in validation...',
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          color: backgroundColor,
          backgroundColor: Colors.transparent,
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
        title: InkWell(
          onTap: () {
            gridViewScrollController.animateTo(
              0,
              duration: Duration(seconds: 2),
              curve: Curves.easeOutQuint
            );
          },
          child: Text(
            'In validation',
            style: TextStyle(
              color: accent,
              fontSize: 25.0,
            ),
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

            fetchTempQuotes();
          },
          order: order,
        ):
        Padding(padding: EdgeInsets.zero,),
      body: Builder(
        builder: (BuildContext context) {
          if (quotes.length ==  0) {
            return EmptyView(
              title: 'No quotes',
              icon: Icon(Icons.speaker_notes_off, size: 60.0),
              description: 'You have no quotes in validation. Go to the Add Quote page to start sharing your thoughts with others.',
              onRefresh: () async {
                await fetchTempQuotes();
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
              await fetchTempQuotes();
              return null;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollNotif) {
                if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
                  return false;
                }

                if (pagination.hasNext && !isLoadingMoreQuotes) {
                  isLoadingMoreQuotes = true;
                  fetchMoreTempQuotes();
                }

                return false;
              },
              child: GridView.builder(
                itemCount: quotes.length,
                padding: EdgeInsets.symmetric(vertical: 20.0),
                controller: gridViewScrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemBuilder: (BuildContext gridViewContext, int index) {
                  return SmallTempQuoteCard(
                    quote: quotes.elementAt(index),
                    onDelete: (String id) async {
                      final quoteToDelete = quotes.elementAt(index);

                      setState(() {
                        quotes.removeWhere((q) => q.id == id);
                      });

                      final booleanMessage = await Mutations.deleteTempQuote(context, id);

                      if (!booleanMessage.boolean) {
                        setState(() {
                          quotes.insert(index, quoteToDelete);
                        });

                        Flushbar(
                          duration: Duration(seconds: 3),
                          backgroundColor: ThemeColor.error,
                          message: booleanMessage.message,
                        )..show(context);
                      }
                    },
                    onDoubleTap: (String id) async {
                      tryValidateQuote(index, id);
                    },
                    onValidate: (String id) async {
                      tryValidateQuote(index, id);
                    },
                  );
                },
              ),
            )
          );
        },
      )
    );
  }

  Future fetchTempQuotes() {
    setState(() {
      isLoading = true;
    });

    return Queries.myTempQuotes(
      context: context,
      lang: lang,
      limit: pagination.limit,
      order: order,
      skip: pagination.skip,

    ).then((quotesResp) {
    setState(() {
        quotes = quotesResp.entries;
        pagination = quotesResp.pagination;
        isLoading = false;
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

  Future fetchMoreTempQuotes() {
    setState(() {
      isLoadingMoreQuotes = true;
    });

    return Queries.myTempQuotes(
      context: context,
      lang: lang,
      limit: pagination.limit,
      order: order,
      skip: pagination.nextSkip,

    ).then((quotesResp) {
      setState(() {
        quotes.addAll(quotesResp.entries);
        pagination = quotesResp.pagination;
        isLoadingMoreQuotes = false;
      });
    })
    .catchError((err) {
      setState(() {
        isLoadingMoreQuotes = false;
      });
    });
  }

  void tryValidateQuote(int index, String id) async {
    final quoteToValidate = quotes.elementAt(index);

    setState(() {
      quotes.removeWhere((q) => q.id == id);
    });

    final booleanMessage = await Mutations.validateTempQuote(context, id);

    if (!booleanMessage.boolean) {
      setState(() {
        quotes.insert(index, quoteToValidate);
      });

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.error,
        message: booleanMessage.message,
      )..show(context);

      return;
    }

    Flushbar(
      backgroundColor: ThemeColor.success,
      message: 'The quote has been successfully validated'
    )..show(context);
  }
}
