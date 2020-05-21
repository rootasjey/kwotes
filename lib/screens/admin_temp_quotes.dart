import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/order_lang_button.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';

class AdminTempQuotes extends StatefulWidget {
  @override
  AdminTempQuotesState createState() => AdminTempQuotesState();
}

class AdminTempQuotesState extends State<AdminTempQuotes> {
  bool hasNext        = true;
  bool hasErrors      = false;
  bool isLoading      = false;
  bool isLoadingMore  = false;
  String lang         = 'en';
  int limit           = 30;
  bool descending     = true;
  final pageRoute     = AdminTempQuotesRoute;

  List<TempQuote> tempQuotes = [];
  ScrollController scrollController = ScrollController();

  var lastDoc;

  @override
  initState() {
    super.initState();
    getSavedLangAndOrder();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            appBar(),
            bodyListContent(),
          ],
        ),
      )
    );
  }

  Widget appBar() {
    return Observer(
      builder: (_) {
        return SliverAppBar(
          floating: true,
          snap: true,
          expandedHeight: 120.0,
          backgroundColor: stateColors.softBackground,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: <Widget>[
              FadeInY(
                delay: 1.0,
                beginY: 50.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: FlatButton(
                    onPressed: () {
                      if (tempQuotes.length == 0) { return; }

                      scrollController.animateTo(
                        0,
                        duration: Duration(seconds: 2),
                        curve: Curves.easeOutQuint
                      );
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 60.0,
                      child: Text(
                        'All in validation',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 20.0,
                top: 50.0,
                child: OrderLangButton(
                  descending: descending,
                  lang: lang,
                  onLangChanged: (String newLang) {
                    appLocalStorage.savePageLang(
                      lang: newLang,
                      pageRoute: pageRoute,
                    );

                    setState(() {
                      lang = newLang;
                    });

                    fetch();
                  },
                  onOrderChanged: (bool order) {
                    appLocalStorage.setPageOrder(
                      descending: order,
                      pageRoute: pageRoute,
                    );

                    setState(() {
                      descending = order;
                    });

                    fetch();
                  },
                ),
              ),

              Positioned(
                left: 20.0,
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
        );
      },
    );
  }

  Widget bodyListContent() {
    if (isLoading) {
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

    if (!isLoading && hasErrors) {
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
                title: "You've no quote in validation at this moment",
                subtitle: 'They will appear after you propose a new quote',
                onRefresh: () => fetch(),
              ),
            ),
          ]
        ),
      );
    }

    return sliverQuotesList();
  }

  Widget sliverQuotesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final quote = tempQuotes.elementAt(index);
          final topicColor = appTopicsColors.find(quote.topics.first);

          return FadeInY(
            delay: index * 1.0,
            beginY: 50.0,
            child: InkWell(
              onTap: () {
                FluroRouter.router.navigateTo(
                  context,
                  QuotePageRoute.replaceFirst(':id', quote.id),
                );
              },
              onLongPress: () => showQuoteSheet(tempQuote: quote),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(top: 20.0),),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      quote.name,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Center(
                    child: IconButton(
                      onPressed: () => showQuoteSheet(tempQuote: quote),
                      icon: Icon(
                        Icons.more_horiz,
                        color: topicColor != null ?
                        Color(topicColor.decimal) : stateColors.primary,
                      ),
                    ),
                  ),

                  Padding(padding: const EdgeInsets.only(top: 10.0),),
                  Divider(),
                ],
              ),
            ),
          );
        },
        childCount: tempQuotes.length,
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

  Future fetch() async {
    setState(() {
      isLoading = true;
      tempQuotes.clear();
    });

    try {
      final snapshot = await Firestore.instance
        .collection('tempquotes')
        .where('lang', isEqualTo: lang)
        .orderBy('createdAt', descending: descending)
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
        .where('lang', isEqualTo: lang)
        .orderBy('createdAt', descending: descending)
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

  void validateAction(TempQuote tempQuote) async {
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

  void getSavedLangAndOrder() {
    lang = appLocalStorage.getPageLang(pageRoute: pageRoute);
    descending = appLocalStorage.getPageOrder(pageRoute: pageRoute);
  }

  void showQuoteSheet({TempQuote tempQuote}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 60.0,
          ),
          child: Wrap(
            spacing: 30.0,
            alignment: WrapAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  IconButton(
                    iconSize: 40.0,
                    tooltip: 'Delete',
                    onPressed: () {
                      FluroRouter.router.pop(context);
                      deleteAction(tempQuote);
                    },
                    icon: Opacity(
                      opacity: .6,
                      child: Icon(
                        Icons.delete_outline,
                      ),
                    ),
                  ),

                  Text(
                    'Delete',
                  ),
                ],
              ),

              Column(
                children: <Widget>[
                  IconButton(
                    iconSize: 40.0,
                    tooltip: 'Edit',
                    onPressed: () {
                      FluroRouter.router.pop(context);
                      editAction(tempQuote);
                    },
                    icon: Opacity(
                      opacity: .6,
                      child: Icon(
                        Icons.edit,
                      ),
                    ),
                  ),

                  Text(
                    'Edit',
                  ),
                ],
              ),

              Column(
                children: <Widget>[
                  IconButton(
                    iconSize: 40.0,
                    onPressed: () {
                      FluroRouter.router.pop(context);
                      validateAction(tempQuote);
                    },
                    icon: Opacity(
                      opacity: .6,
                      child: Icon(
                        Icons.check,
                      ),
                    ),
                  ),

                  Text(
                    'Validate',
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
