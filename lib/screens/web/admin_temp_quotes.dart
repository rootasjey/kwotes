import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/snack.dart';

class AdminTempQuotes extends StatefulWidget {
  @override
  _AdminTempQuotesState createState() => _AdminTempQuotesState();
}

class _AdminTempQuotesState extends State<AdminTempQuotes> {
  final List<TempQuote> tempQuotes = [];

  bool isCheckingAuth = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  bool hasNext = true;

  final scrollController = ScrollController();
  bool isFabVisible = false;

  var lastDoc;

  @override
  initState() {
    super.initState();
    checkAuth();
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
          fetchMore();
        }

        return false;
      },
      child: CustomScrollView(
        controller: scrollController,
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
                onRefresh: () => fetch(),
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
                onTap: () => editAction(tempQuote),
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
                      deleteAction(tempQuote);
                      return;
                    }

                    if (value == 'edit') {
                      editAction(tempQuote);
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
          fetchMore();
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

    final userAuth = await userState.userAuth;
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

  Future<Author> createOrGetAuthor(TempQuote tempQuote) async {
    final author = tempQuote.author;

    // Anonymous author
    if (author.name.isEmpty) {
      final anonymousSnap = await Firestore.instance
        .collection('authors')
        .where('name', isEqualTo: 'Anonymous')
        .getDocuments();

      if (anonymousSnap.documents.isEmpty) {
        throw ErrorDescription('Document not found for Anonymous author.');
      }

      final firstDoc = anonymousSnap.documents.first;

      return Author(
        id: firstDoc.documentID,
        name: 'Anonymous',
      );
    }

    if (author.id.isNotEmpty) {
      return Author(
        id: author.id,
        name: author.name,
      );
    }

    final existingSnapshot = await Firestore.instance
      .collection('authors')
      .where('name', isEqualTo: author.name)
      .getDocuments();

    if (existingSnapshot.documents.isNotEmpty) {
      final existingAuthor = existingSnapshot.documents.first;
      final data = existingAuthor.data;

      return Author(
        id: existingAuthor.documentID,
        name: data['name'],
      );
    }

    final newAuthor = await Firestore.instance
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
      id: newAuthor.documentID,
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

    final existingSnapshot = await Firestore.instance
      .collection('references')
      .where('name', isEqualTo: reference.name)
      .getDocuments();

    if (existingSnapshot.documents.isNotEmpty) {
      final existingRef = existingSnapshot.documents.first;
      final data = existingRef.data;

      return Reference(
        id: existingRef.documentID,
        name: data['name'],
      );
    }

    final newReference = await Firestore.instance
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
      id: newReference.documentID,
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

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isCheckingAuth = false;
        });

        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      setState(() {
        isCheckingAuth = false;
      });

    } catch (error) {
      isCheckingAuth = false;
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void deleteAction(TempQuote tempQuote) async {
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
        message: "Couldn't delete the temporary quote. Details: ${error.toString()}",
        type: SnackType.error,
      );
    }
  }

  void editAction(TempQuote tempQuote) async {
    AddQuoteInputs.navigatedFromPath = 'admintempquotes';
    AddQuoteInputs.populateWithTempQuote(tempQuote);
    FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await Firestore.instance
        .collection('tempquotes')
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
    }
  }

  void fetchMore() async {
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

  void validateTempQuote(TempQuote tempQuote) async {
    int index = tempQuotes.indexOf(tempQuote);

    setState(() {
      tempQuotes.remove(tempQuote);
    });

    try {
      // 1.Get user (for uid)
      final userAuth = await userState.userAuth;

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
      final docQuote = await Firestore.instance
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
        quoteId: docQuote.documentID,
        tempQuote: tempQuote,
      );

      // 7.Delete temp quote
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
        message: "Couldn't validate the temporary quote. Details: ${error.toString()}",
        type: SnackType.error,
      );
    }
  }
}
