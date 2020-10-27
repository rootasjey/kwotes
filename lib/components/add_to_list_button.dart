import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/user_quotes_list.dart';
import 'package:figstyle/utils/snack.dart';

enum ButtonType {
  icon,
  tile,
}

class AddToListButton extends StatefulWidget {
  final Function onBeforeShowSheet;
  final Quote quote;
  final ButtonType type;
  final double size;
  final bool isDisabled;
  final String tooltip;

  AddToListButton(
      {this.onBeforeShowSheet,
      this.isDisabled = false,
      this.quote,
      this.size = 30.0,
      this.type = ButtonType.icon,
      this.tooltip});

  @override
  _AddToListButtonState createState() => _AddToListButtonState();
}

class _AddToListButtonState extends State<AddToListButton> {
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
    if (widget.type == ButtonType.icon) {
      return IconButton(
        tooltip: widget.tooltip,
        iconSize: widget.size,
        icon: Icon(
          Icons.playlist_add,
        ),
        onPressed: widget.isDisabled
            ? null
            : () {
                if (widget.onBeforeShowSheet != null) {
                  widget.onBeforeShowSheet();
                }

                showBottomSheetList();
              },
      );
    }

    return ListTile(
      onTap: widget.isDisabled
          ? null
          : () {
              if (widget.onBeforeShowSheet != null) {
                widget.onBeforeShowSheet();
              }

              showBottomSheetList();
            },
      leading: Icon(Icons.playlist_add),
      title: Text(
        'Add to...',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void showBottomSheetList() {
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
                    fetchMoreLists().then((_) {
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

  Future fetchLists() async {
    isLoading = true;

    try {
      userQuotesLists.clear();
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('lists')
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quoteList = UserQuotesList.fromJSON(data);
        userQuotesLists.add(quoteList);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        hasNext = snapshot.docs.length == limit;
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

  Future fetchMoreLists() async {
    isLoadingMore = true;

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('lists')
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quoteList = UserQuotesList.fromJSON(data);
        userQuotesLists.add(quoteList);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        hasNext = snapshot.docs.length == limit;
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

  void addQuoteToList({String listId}) async {
    final quote = widget.quote;

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('lists')
          .doc(listId)
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

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
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

      return doc.id;
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
}
