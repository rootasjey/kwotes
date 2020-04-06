import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/temp_quote_card_grid_item.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/auth.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/snack.dart';

class TempQuotes extends StatefulWidget {
  @override
  _TempQuotesState createState() => _TempQuotesState();
}

class _TempQuotesState extends State<TempQuotes> {
  final List<TempQuote> tempQuotes = [];

  bool isLoading = false;
  bool isLoadingMore = false;

  bool hasNext = true;

  final _scrollController = ScrollController();
  bool isFabVisible = false;

  FirebaseUser userAuth;

  var lastDoc;

  @override
  initState() {
    super.initState();
    fetchTempQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible ?
        FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0.0,
              duration: Duration(seconds: 1),
              curve: Curves.easeOut,
            );
          },
          backgroundColor: stateColors.primary,
          foregroundColor: Colors.white,
          child: Icon(Icons.arrow_upward),
        ) : null,
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: body(),
          ),

          Column(
            children: <Widget>[
              loadMoreButton(),
              NavBackFooter(),
            ],
          ),

          Footer(),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return FullPageLoading(
        title: 'Loading temporary quotes...',
      );
    }

    return NotificationListener<ScrollNotification>(
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
        if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent - 100.0) {
          return false;
        }

        if (hasNext && !isLoadingMore) {
          fetchMoreTempQuotes();
        }

        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 320.0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FadeInY(
                      beginY: 50.0,
                      child: AppIconHeader(
                        padding: const EdgeInsets.symmetric(vertical: 50.0),
                      ),
                    ),

                    FadeInY(
                      delay: 1.0,
                      beginY: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Temporary quotes',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Positioned(
                  left: 80.0,
                  top: 50.0,
                  child: IconButton(
                    onPressed: () {
                      FluroRouter.router.pop(context);
                    },
                    tooltip: 'Back',
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
              ],
            ),
          ),

          gridContent(),
        ],
      ),
    );
  }

  Widget gridContent() {
    if (tempQuotes.length == 0) {
      return SliverList(
        delegate: SliverChildListDelegate([
            FadeInY(
              delay: 2.0,
              beginY: 50.0,
              child: EmptyContent(
                icon: Opacity(
                  opacity: .8,
                  child: Icon(
                    Icons.sentiment_neutral,
                    size: 120.0,
                    color: Color(0xFFFF005C),
                  ),
                ),
                title: "You've no temporary quote at this moment",
                subtitle: 'They will appear after you propose a new quote',
                onRefresh: () => fetchTempQuotes(),
              ),
            ),
          ]
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final tempQuote = tempQuotes.elementAt(index);
          final topicColor = appTopicsColors.find(tempQuote.topics.first);

          return FadeInY(
            delay: 3.0 + index.toDouble(),
            beginY: 100.0,
            child: SizedBox(
              width: 250.0,
              height: 250.0,
              child: TempQuoteCardGridItem(
                onTap: () => editTempQuote(tempQuote),
                tempQuote: tempQuote,
                popupMenuButton: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    color: topicColor != null ?
                      Color(topicColor.decimal) : Colors.primaries,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      deleteTempQuote(tempQuote);
                      return;
                    }

                    if (value == 'edit') {
                      editTempQuote(tempQuote);
                      return;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_forever),
                        title: Text('Delete'),
                      )
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      )
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: tempQuotes.length,
      ),
    );
  }

  Widget loadMoreButton() {
    if (!hasNext) {
      return Padding(padding: EdgeInsets.zero,);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
        child: FlatButton(
        onPressed: () {
          fetchMoreTempQuotes();
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: stateColors.foreground,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            'Load more...'
          ),
        ),
      ),
    );
  }

  Future createComments({
    TempQuote tempQuote,
    String quoteId,
  }) async {
    final tempComments = tempQuote.comments;

    tempComments.forEach((tempComment) {
      Firestore.instance
        .collection('comments')
        .add({
          'commentId' : '',
          'createdAt' : DateTime.now(),
          'name'      : tempComment,
          'quoteId'   : quoteId,
          'updatedAt' : DateTime.now(),
          'user': {
            'id': userAuth.uid,
          },
        });
    });
  }

  void deleteTempQuote(TempQuote tempQuote) async {
    int index = tempQuotes.indexOf(tempQuote);

    setState(() {
      tempQuotes.remove(tempQuote);
    });

    try {
      await Firestore.instance
        .collection('tempquotes')
        .document(tempQuote.id)
        .delete();

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        tempQuotes.insert(index, tempQuote);
      });

      showSnack(
        context: context,
        message: "Couldn't delete the temporary quote.",
        type: SnackType.error,
      );
    }
  }

  void editTempQuote(TempQuote tempQuote) async {
    AddQuoteInputs.populateWithTempQuote(tempQuote);
    FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
  }

  void fetchTempQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      userAuth = await getUserAuth();

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final snapshot = await Firestore.instance
        .collection('tempquotes')
        .where('user.id', isEqualTo: userAuth.uid)
        .limit(30)
        .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = TempQuote.fromJSON(data);
        tempQuotes.add(quote);
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

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }
    }
  }

  void fetchMoreTempQuotes() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await Firestore.instance
        .collection('tempquotes')
        .startAfterDocument(lastDoc)
        .limit(30)
        .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = TempQuote.fromJSON(data);
        tempQuotes.insert(tempQuotes.length - 1, quote);
      });

      setState(() {
        isLoadingMore = false;
      });

    } catch (error) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }
}
