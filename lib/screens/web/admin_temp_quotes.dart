import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/empty_flat_card.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/load_more_card.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/reference_type.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/types/urls.dart';
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

  FirebaseUser userAuth;

  var lastDoc;

  @override
  initState() {
    super.initState();
    fetchTempQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),
        body(),
        NavBackFooter(),
      ],
    );
  }

  Widget body() {
    if (isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Loading quotes...',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!isLoading && tempQuotes.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height - 300.0,
        child:  EmptyFlatCard(
          onPressed: () => fetchTempQuotes(),
        ),
      );
    }

    return gridQuotes();
  }

  Widget gridQuotes() {
    final children = <Widget>[];

    tempQuotes.forEach((tempQuote) {
      final topicColor = ThemeColor.topicsColors
        .firstWhere((element) => element.name == tempQuote.topics.first);

      children.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: 250.0,
            height: 250.0,
            child: Card(
              shape: BorderDirectional(
                bottom: BorderSide(
                  color: Color(topicColor.decimal),
                  width: 2.0,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      editTempQuote(tempQuote);
                    },
                    child: SizedBox.expand(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              tempQuote.name,
                              style: TextStyle(
                                fontSize: adaptativeFont(tempQuote.name),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: PopupMenuButton<String>(
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
                ],
              ),
            ),
          ),
        )
      );
    });

    children.add(
      LoadMoreCard(
        isLoading: isLoadingMore,
        onTap: () {
          fetchTempQuotesMore();
        },
      )
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Text(
            'Quotes in validation',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),

        Wrap(
          children: children,
        ),
      ],
    );
  }

  double adaptativeFont(String text) {
    if (text.length > 120) {
      return 14.0;
    }

    if (text.length > 90) {
      return 16.0;
    }

    if (text.length > 60) {
      return 18.0;
    }

    return 20.0;
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
        'lang'      : reference.lang,
        'linkedRefs': [],
        'name'      : reference.name,
        'summary'   : reference.summary,
        'type'      : ReferenceType(
          primary   : reference.type.primary,
          secondary : reference.type.secondary,
        ),
        'urls'      : Urls(
          affiliate : reference.urls.affiliate,
          image     : reference.urls.image,
          website   : reference.urls.website,
          wikipedia : reference.urls.wikipedia,
        ),
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

  void fetchTempQuotesMore() async {
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

      Flushbar(
        duration        : Duration(seconds: 3),
        backgroundColor : Colors.green,
        message         : 'The quote has been successfully validated!',
      )..show(context);

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
