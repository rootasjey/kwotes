import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/actions/lists.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/user_quotes_list.dart';
import 'package:figstyle/utils/flash_helper.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class UserLists extends StatefulWidget {
  final ScrollController scrollController;
  final Quote quote;

  UserLists({this.scrollController, @required this.quote});

  @override
  _UserListsState createState() => _UserListsState();
}

class _UserListsState extends State<UserLists> {
  bool hasErrors = false;
  bool isLoading = false;
  bool isLoaded = false;
  bool hasNext = false;
  bool isLoadingMore = false;

  DocumentSnapshot lastDoc;

  Error error;

  final limit = 10;

  List<UserQuotesList> userQuotesLists = [];

  String newListName = '';
  String newListDescription = '';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: body(),
    );
  }

  Widget body() {
    List<Widget> tiles = [];

    if (hasErrors) {
      tiles.add(errorTileList(onPressed: () async {
        await fetchLists();
        setState(() {
          isLoaded = true;
        });
      }));
    }

    if (userQuotesLists.length == 0 && !isLoading && !isLoaded) {
      tiles.add(LinearProgressIndicator());

      fetchLists().then((_) {
        setState(() {
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
        if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
          return false;
        }

        if (hasNext && !isLoadingMore) {
          fetchListsMore().then((_) {
            setState(() {
              isLoadingMore = false;
            });
          });
        }

        return false;
      },
      child: ListView(
        shrinkWrap: true,
        controller: widget.scrollController,
        children: <Widget>[
          createListButton(),
          Divider(
            thickness: 2.0,
          ),
          ...tiles
        ],
      ),
    );
  }

  Widget createListButton() {
    return ListTile(
      onTap: () async {
        final isListCreated = await showCreateListDialog(context);

        if (isListCreated != null && isListCreated) {
          Navigator.pop(context);
        }
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0.6,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.add),
            ),
          ),
          Text(
            'Create list',
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
          TextButton(
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
    Snack.s(
      context: context,
      title: "Add",
      message: "Your quote has been successfully added!",
    );

    final success = await ListsActions.addQuote(
      listId: listId,
      quoteIds: [widget.quote.id],
    );

    if (!success) {
      Snack.e(
        context: context,
        message: "There was an error while adding the quote to the list.",
      );

      return;
    }
  }

  void createListAndAddQuote(BuildContext context) async {
    FlashHelper.showProgress(
      context,
      title: "Create",
      progressId: 'create_list',
      message: "Creating list $newListName...",
      icon: Icon(UniconsLine.plus),
      duration: 60.seconds,
    );

    final createdList = await ListsActions.create(
      name: newListName,
      description: newListDescription,
      isPublic: false,
      quoteIds: [widget.quote.id],
    );

    FlashHelper.dismissProgress(id: 'create_list');

    if (createdList == null) {
      Snack.e(
        context: context,
        message: "There was and issue while creating the list. "
            "Try again later or contact us if the problem persists.",
      );

      return;
    }

    Snack.e(
      context: context,
      title: "Create",
      message: "Your list $newListName has been successfully created!",
    );
  }

  Future fetchLists() async {
    isLoading = true;

    try {
      userQuotesLists.clear();
      final userAuth = stateUser.userAuth;

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

      Snack.e(
        context: context,
        message: 'Cannot retrieve your lists right now',
      );
    }
  }

  Future fetchListsMore() async {
    isLoadingMore = true;

    try {
      final userAuth = stateUser.userAuth;

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

      Snack.e(
        context: context,
        message: 'Cannot retrieve more lists.',
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 25.0,
          ),
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
                TextButton(
                  onPressed: () {
                    return Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
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
      },
    );
  }
}
