import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/quote_row.dart';
import 'package:memorare/components/quote_row_with_actions.dart';
import 'package:memorare/components/simple_appbar.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/home_app_bar.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/app_localstorage.dart';

enum SubjectType {
  author,
  reference,
}

class QuotesByAuthorRef extends StatefulWidget {
  final String id;
  final SubjectType type;

  QuotesByAuthorRef({
    this.id = '',
    this.type = SubjectType.reference,
  });

  @override
  _QuotesByAuthorRefState createState() => _QuotesByAuthorRefState();
}

class _QuotesByAuthorRefState extends State<QuotesByAuthorRef> {
  bool hasNext        = true;
  bool hasErrors      = false;
  bool isFabVisible   = false;
  bool isLoading      = false;
  bool isLoadingMore  = false;
  String lang         = 'en';
  int limit           = 30;
  bool descending     = true;
  String pageRoute    = '';
  String subjectName  = '';

  ScrollController scrollController = ScrollController();
  List<Quote> quotes = [];

  var lastDoc;

  @override
  initState() {
    super.initState();

    pageRoute = widget.type == SubjectType.author
      ? AuthorQuotesRoute
      : ReferenceQuotesRoute;

    getSavedProps();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible ?
        FloatingActionButton(
          onPressed: () {
            scrollController.animateTo(
              0.0,
              duration: Duration(seconds: 1),
              curve: Curves.easeOut,
            );
          },
          backgroundColor: stateColors.primary,
          foregroundColor: Colors.white,
          child: Icon(Icons.arrow_upward),
        ) : null,
      body: body(),
    );
  }

  Widget body() {
    return RefreshIndicator(
      onRefresh: () async {
        await fetch();
        return null;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotif) {
          // FAB visibility
          if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
            setState(() {
              isFabVisible = false;
            });
          } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
            setState(() {
              isFabVisible = true;
            });
          }

          // Load more scenario
          if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
            return false;
          }

          if (hasNext && !isLoadingMore) {
            fetchMore();
          }

          return false;
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            HomeAppBar(),
            appBar(),
            bodyListContent(),
          ],
        ),
      )
    );
  }

  Widget appBar() {
    return SimpleAppBar(
      textTitle: "Quotes of $subjectName",
      subHeader: Observer(
        builder: (context) {
          return Wrap(
            spacing: 10.0,
            children: <Widget>[
              FadeInY(
                beginY: 10.0,
                delay: 2.0,
                child: ChoiceChip(
                  label: Text(
                    'First added',
                    style: TextStyle(
                      color: !descending ?
                        Colors.white :
                        stateColors.foreground,
                    ),
                  ),
                  selected: !descending,
                  selectedColor: stateColors.primary,
                  onSelected: (selected) {
                    if (!descending) { return; }

                    descending = false;
                    fetch();

                    appLocalStorage.setPageOrder(
                      descending: descending,
                      pageRoute: pageRoute,
                    );
                  },
                ),
              ),

              FadeInY(
                beginY: 10.0,
                delay: 2.5,
                child: ChoiceChip(
                  label: Text(
                    'Last added',
                    style: TextStyle(
                      color: descending ?
                        Colors.white :
                        stateColors.foreground,
                    ),
                  ),
                  selected: descending,
                  selectedColor: stateColors.primary,
                  onSelected: (selected) {
                    if (descending) { return; }

                    descending = true;
                    fetch();

                    appLocalStorage.setPageOrder(
                      descending: descending,
                      pageRoute: pageRoute,
                    );
                  },
                ),
              ),

              FadeInY(
                beginY: 10.0,
                delay: 3.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Container(
                    height: 25,
                    width: 2.0,
                    color: stateColors.foreground.withOpacity(0.5),
                  ),
                ),
              ),

              FadeInY(
                beginY: 10.0,
                delay: 3.5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: DropdownButton<String>(
                    elevation: 2,
                    value: lang,
                    isDense: true,
                    underline: Container(
                      height: 0,
                      color: Colors.deepPurpleAccent,
                    ),
                    icon: Icon(Icons.keyboard_arrow_down),
                    style: TextStyle(
                      color: stateColors.foreground.withOpacity(0.6),
                      fontFamily: 'Comfortaa',
                      fontSize: 20.0,
                    ),
                    onChanged: (String newLang) {
                      lang = newLang;
                      fetch();

                      appLocalStorage.setPageLang(
                        lang: newLang,
                        pageRoute: pageRoute,
                      );
                    },
                    items: ['en', 'fr'].map((String value) {
                      return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value.toUpperCase(),
                          ));
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget bodyListContent() {
    if (isLoading) {
      return loadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (quotes.length == 0) {
      return emptyView();
    }

    return sliverQuotesList();
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
          FadeInY(
            delay: 2.0,
            beginY: 50.0,
            child: EmptyContent(
              icon: Opacity(
                opacity: .8,
                child: Icon(
                  Icons.speaker_notes_off,
                  size: 120.0,
                  color: Color(0xFFFF005C),
                ),
              ),
              title: "There's no quote in this language",
              subtitle: 'You can try another language',
              onRefresh: () => fetch(),
            ),
          ),
        ]
      ),
    );
  }

  Widget errorView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: ErrorContainer(
            onRefresh: () => fetch(),
          ),
        ),
      ]),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: LoadingAnimation(),
          ),
        ]
      ),
    );
  }

  Widget sliverQuotesList() {
    return Observer(
      builder: (context) {
        if (userState.isUserConnected) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final quote = quotes.elementAt(index);
                return QuoteRowWithActions(
                  quote: quote,
                  quoteId: quote.id,
                );
              },
              childCount: quotes.length,
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final quote = quotes.elementAt(index);

              return QuoteRow(
                quote: quote,
                quoteId: quote.id,
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                  ),
                ),
              ],
                onSelected: (value) {
                  switch (value) {
                    case 'share':
                      shareTwitter(quote: quote);
                      break;
                    default:
                  }
                },
              );
            },
            childCount: quotes.length,
          ),
        );
      },
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
    });

    lastDoc = null;
    quotes.clear();

    try {
      fetchSubject();

      final snapshot = await fetchSnapshot();

      if (snapshot.documents.isEmpty) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.documents.last;

      setState(() {
        isLoading = false;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMore() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await fetchNextSnapshot();

      if (snapshot.documents.isEmpty) {
        setState(() {
          isLoadingMore = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = Quote.fromJSON(data);
        quotes.insert(quotes.length - 1, quote);
      });

      setState(() {
        isLoadingMore = false;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void fetchSubject() async {
    DocumentSnapshot snapshot;

    if (widget.type == SubjectType.author) {
      snapshot = await Firestore.instance
        .collection('authors')
        .document(widget.id)
        .get();

    } else {
      snapshot = await Firestore.instance
        .collection('references')
        .document(widget.id)
        .get();
    }

    if (snapshot == null) {
      return;
    }

    setState(() {
      subjectName = snapshot.data['name'];
    });
  }

  /// Handle subject type.
  Future<QuerySnapshot> fetchSnapshot() async {
    if (widget.type == SubjectType.author) {
      return await Firestore.instance
        .collection('quotes')
        .where('author.id', isEqualTo: widget.id)
        .where('lang', isEqualTo: lang)
        .orderBy('createdAt', descending: descending)
        .limit(30)
        .getDocuments();
    }

    return await Firestore.instance
      .collection('quotes')
      .where('mainReference.id', isEqualTo: widget.id)
      .where('lang', isEqualTo: lang)
      .orderBy('createdAt', descending: descending)
      .limit(30)
      .getDocuments();
  }

  /// Handle subject type.
  Future<QuerySnapshot> fetchNextSnapshot() async {
    if (widget.type == SubjectType.author) {
      return await Firestore.instance
        .collection('quotes')
        .where('author.id', isEqualTo: widget.id)
        .where('lang', isEqualTo: lang)
        .orderBy('createdAt', descending: descending)
        .startAfterDocument(lastDoc)
        .limit(30)
        .getDocuments();
    }

    return await Firestore.instance
      .collection('quotes')
      .where('mainReference.id', isEqualTo: widget.id)
      .where('lang', isEqualTo: lang)
      .orderBy('createdAt', descending: descending)
      .startAfterDocument(lastDoc)
      .limit(30)
      .getDocuments();
  }

  void getSavedProps() {
    lang        = appLocalStorage.getPageLang(pageRoute: pageRoute);
    descending  = appLocalStorage.getPageOrder(pageRoute: pageRoute);
  }
}
