import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/quotes.dart';
import 'package:memorare/actions/quotidians.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/quote_row.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/enums.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/user_quotes_list.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';

class QuoteRowWithActions extends StatefulWidget {
  final bool canManage;
  final bool isConnected;

  final Function onAfterAddToFavourites;
  final Function onAfterDeletePubQuote;
  final Function onAfterRemoveFromFavourites;
  final Function onAfterRemoveFromList;
  final Function onBeforeAddToFavourites;
  final Function onBeforeDeletePubQuote;
  final Function onBeforeRemoveFromFavourites;
  final Function onBeforeRemoveFromList;
  final Function onRemoveFromList;

  final ItemComponentType componentType;

  final EdgeInsets padding;

  final Quote quote;
  final QuotePageType quotePageType;

  /// Specify explicitly the quote'is
  /// because quote's id in favourites reflect
  /// the favourite's id and no the quote.
  final String quoteId;
  final String pageRoute;

  final List<Widget> stackChildren;

  QuoteRowWithActions({
    this.canManage = false,
    this.isConnected = false,
    this.componentType = ItemComponentType.row,
    this.onAfterAddToFavourites,
    this.onAfterDeletePubQuote,
    this.onAfterRemoveFromFavourites,
    this.onAfterRemoveFromList,
    this.onBeforeAddToFavourites,
    this.onBeforeDeletePubQuote,
    this.onBeforeRemoveFromFavourites,
    this.onBeforeRemoveFromList,
    this.onRemoveFromList,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.pageRoute = '',
    @required this.quote,
    this.quoteId,
    this.quotePageType = QuotePageType.published,
    this.stackChildren = const [],
  });

  @override
  _QuoteRowWithActionsState createState() => _QuoteRowWithActionsState();
}

class _QuoteRowWithActionsState extends State<QuoteRowWithActions> {
  List<UserQuotesList> userQuotesLists = [];

  String newListName = '';
  String newListDescription = '';

  int order = -1;
  int limit = 10;

  bool hasNext = true;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool isLoaded = false;

  bool hasErrors = false;
  Error error;

  var lastDoc;

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final popupItems = getPopupItems();

    return QuoteRow(
      quote: quote,
      quoteId: widget.quoteId,
      padding: widget.padding,
      itemBuilder: (context) => popupItems,
      onSelected: onSelected,
      componentType: widget.componentType,
      stackChildren: widget.stackChildren,
    );
  }

  void onSelected(value) async {
    final quote = widget.quote;

    switch (value) {
      case 'addtofavourites':
        if (widget.onBeforeAddToFavourites != null) {
          widget.onBeforeAddToFavourites();
        }

        final success = await addToFavourites(
          context: context,
          quote: quote,
        );

        if (widget.onAfterAddToFavourites != null) {
          widget.onAfterAddToFavourites(success);
        }

        if (success) {
          showSnack(
            context: context,
            message: 'The quote has been successfully added to favourites.',
            type: SnackType.success,
          );
        }

        break;
      case 'addtolist':
        showBottomSheetList();
        break;
      case 'removefromfavourites':
        if (widget.onBeforeRemoveFromFavourites != null) {
          widget.onBeforeRemoveFromFavourites();
        }

        final success = await removeFromFavourites(
          context: context,
          quote: quote,
        );

        if (widget.onAfterRemoveFromFavourites != null) {
          widget.onAfterRemoveFromFavourites(success);
        }

        break;
      case 'removefromlist':
        widget.onRemoveFromList(quote);
        break;
      case 'share':
        shareQuote(context: context, quote: quote);
        break;
      case 'addquotidian':
        final pageRoute = widget.pageRoute;
        final lang = pageRoute.isEmpty
            ? 'en'
            : appLocalStorage.getPageLang(pageRoute: pageRoute);

        await addToQuotidians(
          quote: quote,
          lang: lang,
        );

        break;
      case 'deletequote':
        deletePubQuote();
        break;
      default:
    }
  }

  Widget newListButton() {
    return ListTile(
      onTap: () async {
        final res = await showCreateListDialog(context);
        if (res != null && res) {
          Navigator.pop(context);
        }
      },
      // leading: Icon(Icons.add),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: .6,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.add),
            ),
          ),
          Text(
            'New list',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget errorTileList({Function onPressed}) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text('There was an issue while loading your lists.'),
          FlatButton(
            onPressed: () {
              if (onPressed != null) {
                onPressed();
              }
            },
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('Retry'),
            ),
          )
        ],
      ),
    );
  }

  Widget tileList(UserQuotesList list) {
    return ListTile(
      onTap: () {
        addQuoteToList(
          listId: list.id,
        );

        Navigator.pop(context);
      },
      title: Center(
        child: Text(
          list.name,
        ),
      ),
    );
  }

  void addQuoteToList({String listId}) async {
    final quote = widget.quote;

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        return;
      }

      await Firestore.instance
          .collection('users')
          .document(userAuth.uid)
          .collection('lists')
          .document(listId)
          .collection('quotes')
          .add({
        'author': {
          'id': quote.author.id,
          'name': quote.author.name,
        },
        'createdAt': DateTime.now(),
        'name': quote.name,
        'quoteId': quote.id,
        'topics': quote.topics,
      });
    } catch (err) {
      debugPrint(err.toString());

      showSnack(
        context: context,
        message: 'There was an error while adding the quote to the list.',
        type: SnackType.error,
      );
    }
  }

  void createListAndAddQuote(BuildContext context) async {
    final listId = await createList();

    if (listId == null) {
      return;
    }

    addQuoteToList(listId: listId);
  }

  Future<String> createList() async {
    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        return null;
      }

      final docRef = await Firestore.instance
          .collection('users')
          .document(userAuth.uid)
          .collection('lists')
          .add({
        'createdAt': DateTime.now(),
        'description': newListDescription,
        'name': newListName,
        'iconUrl': '',
        'isPublic': false,
        'updatedAt': DateTime.now(),
      });

      final doc = await docRef.get();

      return doc.documentID;
    } catch (error) {
      debugPrint(error.toString());

      showSnack(
        context: context,
        message: 'There was and issue while creating the list. Try again later',
        type: SnackType.error,
      );

      return null;
    }
  }

  Future fetchLists() async {
    isLoading = true;

    try {
      userQuotesLists.clear();
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        return;
      }

      final snapshot = await Firestore.instance
          .collection('users')
          .document(userAuth.uid)
          .collection('lists')
          .limit(limit)
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

        final quoteList = UserQuotesList.fromJSON(data);
        userQuotesLists.add(quoteList);
      });

      lastDoc = snapshot.documents.last;

      setState(() {
        hasNext = snapshot.documents.length == limit;
        isLoading = false;
      });
    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoading = false;
        error = err;
        hasErrors = false;
      });

      showSnack(
        context: context,
        message: 'Cannot retrieve your lists right now',
        type: SnackType.error,
      );
    }
  }

  Future fetchListsMore() async {
    isLoadingMore = true;

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        return;
      }

      final snapshot = await Firestore.instance
          .collection('users')
          .document(userAuth.uid)
          .collection('lists')
          .startAfterDocument(lastDoc)
          .limit(limit)
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

        final quoteList = UserQuotesList.fromJSON(data);
        userQuotesLists.add(quoteList);
      });

      lastDoc = snapshot.documents.last;

      setState(() {
        hasNext = snapshot.documents.length == limit;
        isLoadingMore = false;
      });
    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoadingMore = false;
        error = err;
        hasErrors = false;
      });

      showSnack(
        context: context,
        message: 'Cannot retrieve more lists.',
        type: SnackType.error,
      );
    }
  }

  void showBottomSheetList() {
    if (!userState.isUserConnected) {
      showSnack(
        context: context,
        message: "You must sign in to add this quote to a list.",
        type: SnackType.error,
      );

      return;
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setSheetState) {
              List<Widget> tiles = [];

              if (hasErrors) {
                tiles.add(errorTileList(onPressed: () async {
                  await fetchLists();
                  setSheetState(() {
                    isLoaded = true;
                  });
                }));
              }

              if (userQuotesLists.length == 0 && !isLoading && !isLoaded) {
                tiles.add(LinearProgressIndicator());

                fetchLists().then((_) {
                  setSheetState(() {
                    isLoaded = true;
                  });
                });
              }

              if (userQuotesLists.length > 0) {
                for (var list in userQuotesLists) {
                  tiles.add(tileList(list));
                }
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollNotif) {
                  if (scrollNotif.metrics.pixels <
                      scrollNotif.metrics.maxScrollExtent) {
                    return false;
                  }

                  if (hasNext && !isLoadingMore) {
                    fetchListsMore().then((_) {
                      setSheetState(() {
                        isLoadingMore = false;
                      });
                    });
                  }

                  return false;
                },
                child: ListView(
                  children: <Widget>[
                    newListButton(),
                    Divider(
                      thickness: 2.0,
                    ),
                    ...tiles
                  ],
                ),
              );
            },
          );
        });
  }

  Future<bool> showCreateListDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Create a new list'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
            children: <Widget>[
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Name',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
                onChanged: (newValue) {
                  newListName = newValue;
                },
                onSubmitted: (_) {
                  createListAndAddQuote(context);
                  return Navigator.of(context).pop(true);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
                onChanged: (newValue) {
                  newListDescription = newValue;
                },
                onSubmitted: (_) {
                  createListAndAddQuote(context);
                  return Navigator.of(context).pop(true);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      return Navigator.of(context).pop(false);
                    },
                    child: Text(
                      'Cancel',
                    ),
                  ),
                  RaisedButton(
                    color: Colors.green,
                    onPressed: () {
                      createListAndAddQuote(context);
                      return Navigator.of(context).pop(true);
                    },
                    child: Text(
                      'Create',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ],
          );
        });
  }

  void deletePubQuote() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'Confirm deletion?',
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(3.0),
                      ),
                    ),
                    color: stateColors.softBackground,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 15.0,
                      ),
                      child: Text(
                        'NO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 15.0)),
                  RaisedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      if (widget.onBeforeDeletePubQuote != null) {
                        widget.onBeforeDeletePubQuote();
                      }

                      final success = await deleteQuote(quote: widget.quote);

                      if (widget.onAfterDeletePubQuote != null) {
                        widget.onAfterDeletePubQuote(success);
                      }
                    },
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(3.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 15.0,
                      ),
                      child: Text(
                        'YES',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  List<PopupMenuEntry<String>> getPopupItems() {
    final popupItems = <PopupMenuEntry<String>>[
      PopupMenuItem(
        value: 'share',
        child: ListTile(
          leading: Icon(Icons.share),
          title: Text('Share'),
        ),
      ),
    ];

    if (widget.quotePageType == QuotePageType.published && widget.isConnected) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'addtofavourites',
          child: ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Add to favourites'),
          ),
        ),
        PopupMenuItem(
          value: 'addtolist',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Add to...'),
          ),
        ),
      ]);
    } else if (widget.quotePageType == QuotePageType.favourites) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'removefromfavourites',
          child: ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Remove from favourites'),
          ),
        ),
        PopupMenuItem(
          value: 'addtolist',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Add to...'),
          ),
        ),
      ]);
    } else if (widget.quotePageType == QuotePageType.list) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'addtofavourites',
          child: ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Add to favourites'),
          ),
        ),
        PopupMenuItem(
          value: 'addtolist',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Add to...'),
          ),
        ),
      ]);
    }

    if (widget.canManage) {
      popupItems.addAll([
        PopupMenuItem(
            value: 'addquotidian',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Add to quotidians'),
            )),
        PopupMenuItem(
            value: 'deletequote',
            child: ListTile(
              leading: Icon(Icons.delete_forever),
              title: Text('Delete published'),
            )),
      ]);
    }

    return popupItems;
  }
}
