import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/temp_quote_card_grid_item.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class AdminTempQuotes extends StatefulWidget {
  @override
  _AdminTempQuotesState createState() => _AdminTempQuotesState();
}

class _AdminTempQuotesState extends State<AdminTempQuotes> {
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
            child: gridQuotes(),
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

    return gridQuotes();
  }

  Widget gridQuotes() {
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
                      child: AppIconHeader(),
                    ),

                    FadeInY(
                      delay: 1.0,
                      beginY: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'All temporary quotes',
                            style: TextStyle(
                              fontSize: 30.0,
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
                title: "There're no temporary quote at this moment",
                subtitle: 'They will appear after people add new quotes',
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
                onLongPress: () => validateTempQuote(tempQuote),
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

                    if (value == 'validate') {
                      validateTempQuote(tempQuote);
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
                    PopupMenuItem(
                      value: 'validate',
                      child: ListTile(
                        leading: Icon(Icons.check),
                        title: Text('Validate'),
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
      FirestoreApp.instance
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

  Future<Author> createOrGetAuthor(TempQuote tempQuote) async {
    final author = tempQuote.author;

    // Anonymous author
    if (author.name.isEmpty) {
      final anonymousSnap = await FirestoreApp.instance
        .collection('authors')
        .where('name', '==', 'Anonymous')
        .get();

      if (anonymousSnap.empty) {
        throw ErrorDescription('Document not found for Anonymous author.');
      }

      final firstDoc = anonymousSnap.docs.first;

      return Author(
        id: firstDoc.id,
        name: 'Anonymous',
      );
    }

    if (author.id.isNotEmpty) {
      return Author(
        id: author.id,
        name: author.name,
      );
    }

    final existingSnapshot = await FirestoreApp.instance
      .collection('authors')
      .where('name', '==', author.name)
      .get();

    if (!existingSnapshot.empty) {
      final existingAuthor = existingSnapshot.docs.first;
      final data = existingAuthor.data();

      return Author(
        id: existingAuthor.id,
        name: data['name'],
      );
    }

    final newAuthor = await FirestoreApp.instance
      .collection('authors')
      .add({
        'job'         : author.job,
        'jobLang'     : {},
        'name'        : author.name,
        'summary'     : author.summary,
        'summaryLang' : {},
        'updatedAt'   : DateTime.now(),
        'urls'        : {
          'affiliate' : author.urls.affiliate,
          'image'     : author.urls.image,
          'website'   : author.urls.website,
          'wikipedia' : author.urls.wikipedia,
        }
      });

    return Author(
      id: newAuthor.id,
      name: author.name,
    );
  }

  Future<Reference> createOrGetReference(TempQuote tempQuote) async {
    if (tempQuote.references.length == 0) {
      return Reference();
    }

    final reference = tempQuote.references.first;

    if (reference.id.isNotEmpty) {
      return Reference(
        id: reference.id,
        name: reference.name,
      );
    }

    final existingSnapshot = await FirestoreApp.instance
      .collection('references')
      .where('name', '==', reference.name)
      .get();

    if (!existingSnapshot.empty) {
      final existingRef = existingSnapshot.docs.first;
      final data = existingRef.data();

      return Reference(
        id: existingRef.id,
        name: data['name'],
      );
    }

    final newReference = await FirestoreApp.instance
      .collection('references')
      .add({
        'createdAt' : DateTime.now(),
        'lang'      : reference.lang,
        'linkedRefs': [],
        'name'      : reference.name,
        'summary'   : reference.summary,
        'type'      : {
          'primary'   : reference.type.primary,
          'secondary' : reference.type.secondary,
        },
        'updatedAt' : DateTime.now(),
        'urls'      : {
          'affiliate' : reference.urls.affiliate,
          'image'     : reference.urls.image,
          'website'   : reference.urls.website,
          'wikipedia' : reference.urls.wikipedia,
        },
      });

    return Reference(
      id: newReference.id,
      name: reference.name,
    );
  }

  Map<String, dynamic> createTopicsMap(TempQuote tempQuote) {
    final Map<String, dynamic> topicsMap = {};

      tempQuote.topics.forEach((topic) {
        topicsMap[topic] = true;
      });

    return topicsMap;
  }

  void deleteTempQuote(TempQuote tempQuote) async {
    int index = tempQuotes.indexOf(tempQuote);

    setState(() {
      tempQuotes.remove(tempQuote);
    });

    try {
      await FirestoreApp.instance
        .collection('tempquotes')
        .doc(tempQuote.id)
        .delete();

      Flushbar(
        duration        : Duration(seconds: 3),
        backgroundColor : Colors.green,
        message         : 'The temporary quote has been successfully deleted.',
      )..show(context);

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        tempQuotes.insert(index, tempQuote);
      });

      Flushbar(
        duration        : Duration(seconds: 3),
        backgroundColor : Colors.red,
        message         : "Couldn't delete the temporary quote. Details: ${error.toString()}",
      )..show(context);
    }
  }

  void editTempQuote(TempQuote tempQuote) async {
    AddQuoteInputs.navigatedFromPath = 'admintempquotes';
    AddQuoteInputs.populateWithTempQuote(tempQuote);
    FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
  }

  void fetchTempQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('tempquotes')
        .limit(30)
        .get();

      if (snapshot.empty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = TempQuote.fromJSON(data);
        tempQuotes.add(quote);
      });

      lastDoc = snapshot.docs.last;

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

  void fetchMoreTempQuotes() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final snapshot = await FirestoreApp.instance
        .collection('tempquotes')
        .startAfter(snapshot: lastDoc)
        .limit(30)
        .get();

      if (snapshot.empty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

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

  void validateTempQuote(TempQuote tempQuote) async {
    int index = tempQuotes.indexOf(tempQuote);

    setState(() {
      tempQuotes.remove(tempQuote);
    });

    try {
      // 1.Get user (for uid)
      userAuth = await FirebaseAuth.instance.currentUser();

      // 2.Create or get author if any
      final author = await createOrGetAuthor(tempQuote);

      // 3.Create or get reference if any
      final reference = await createOrGetReference(tempQuote);
      final referencesArray = [];

      if (reference.id.isNotEmpty) {
        referencesArray.add({
          'id': reference.id,
          'name': reference.name,
        });
      }

      // 4.Create topics map
      final topics = createTopicsMap(tempQuote);

      // 5.Format data and add new quote
      final docQuote = await FirestoreApp.instance
        .collection('quotes')
        .add({
          'author'        : {
            'id'          : author.id,
            'name'        : author.name,
          },
          'createdAt'     : DateTime.now(),
          'lang'          : tempQuote.lang,
          'links'         : [],
          'mainReference' : {
            'id'  : reference.id,
            'name': reference.name,
          },
          'name'          : tempQuote.name,
          'references'    : referencesArray,
          'region'        : tempQuote.region,
          'stats': {
            'likes'       : 0,
            'shares'      : 0,
          },
          'topics'        : topics,
          'updatedAt'     : DateTime.now(),
          'user': {
            'id': userAuth.uid,
          }
        });

      // 6.Create comment if any
      await createComments(
        quoteId: docQuote.id,
        tempQuote: tempQuote,
      );

      // 7.Delete temp quote
      await FirestoreApp.instance
        .collection('tempquotes')
        .doc(tempQuote.id)
        .delete();

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        tempQuotes.insert(index, tempQuote);
      });

      Flushbar(
        duration        : Duration(seconds: 3),
        backgroundColor : Colors.red,
        message         : "Couldn't validate the temporary quote. Details: ${error.toString()}",
      )..show(context);
    }
  }
}
