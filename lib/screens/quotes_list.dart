import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/lists.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/base_page_app_bar.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/user_quotes_list.dart';
import 'package:figstyle/utils/snack.dart';

class QuotesList extends StatefulWidget {
  final String id;

  QuotesList({
    @required this.id,
  });

  @override
  _QuotesListState createState() => _QuotesListState();
}

class _QuotesListState extends State<QuotesList> {
  bool descending = true;
  bool hasErrors = false;
  bool hasNext = true;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isDeletingList = false;
  bool updateListIsPublic = false;

  DocumentSnapshot lastDoc;

  final scrollController = ScrollController();

  int limit = 10;

  List<Quote> quotes = [];

  ScrollController listScrollController = ScrollController();

  String updateListName = '';
  String updateListDesc = '';

  UserQuotesList quotesList;

  @override
  initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: () async {
            await fetch();
            return null;
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotif) {
              if (scrollNotif.metrics.pixels <
                  scrollNotif.metrics.maxScrollExtent) {
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
                body(),
              ],
            ),
          )),
    );
  }

  Widget appBar() {
    return BasePageAppBar(
      expandedHeight: 110.0,
      title: Padding(
        padding: const EdgeInsets.only(left: 0.0, top: 0.0),
        child: Row(
          children: [
            CircleButton(
                onTap: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, color: stateColors.foreground)),
            AppIcon(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              size: 30.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quotesList == null ? 'List' : quotesList.name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w300,
                      color: stateColors.foreground,
                    ),
                  ),
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      quotesList == null ? '' : quotesList.description,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: stateColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Wrap(
            spacing: 20.0,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () => showEditListDialog(),
                icon: Icon(Icons.edit),
                label: Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: () => showDeleteListDialog(),
                icon: Icon(Icons.delete),
                label: Text('Delete'),
                style: OutlinedButton.styleFrom(
                  primary: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return loadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (quotes.length == 0) {
      return emptyView();
    }

    return listView();
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 0.2,
          beginY: 50.0,
          child: Container(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Opacity(
                    opacity: .8,
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 100.0,
                      color: Color(0xFFFF005C),
                    ),
                  ),
                ),
                Opacity(
                  opacity: .8,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Text(
                      'No quote yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: Opacity(
                    opacity: .6,
                    child: Text(
                      "You can add some from other pages",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
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
      ]),
    );
  }

  Widget popupMenuButton() {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case 'delete':
            showDeleteListDialog();
            break;
          case 'edit':
            showEditListDialog();
            break;
          default:
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
          ),
        ),
      ],
    );
  }

  Widget listView() {
    final horPadding = MediaQuery.of(context).size.width < 700.00 ? 0.0 : 70.0;

    return SliverPadding(
      padding: const EdgeInsets.only(top: 20.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final quote = quotes.elementAt(index);

            return QuoteRowWithActions(
              quote: quote,
              quoteId: quote.quoteId,
              color: stateColors.appBackground,
              quotePageType: QuotePageType.list,
              onRemoveFromList: () => removeQuote(quote),
              padding: EdgeInsets.symmetric(
                horizontal: horPadding,
              ),
            );
          },
          childCount: quotes.length,
        ),
      ),
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      quotes.clear();

      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isLoading = false;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final docList = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('lists')
          .doc(widget.id)
          .get();

      if (!docList.exists) {
        showSnack(
          context: context,
          message: "This list doesn't' exist anymore",
          type: SnackType.error,
        );

        Navigator.of(context).pop();
        return;
      }

      final data = docList.data();
      data['id'] = docList.id;
      quotesList = UserQuotesList.fromJSON(data);

      updateListIsPublic = quotesList.isPublic;

      final collSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('lists')
          .doc(quotesList.id)
          .collection('quotes')
          .limit(limit)
          .get();

      if (collSnap.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      collSnap.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        hasNext = collSnap.docs.length == limit;
        isLoading = false;
      });
    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMore() async {
    setState(() {
      isLoadingMore = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isLoadingMore = false;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('lists')
          .doc(quotesList.id)
          .collection('quotes')
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        hasNext = snapshot.docs.length == limit;
        isLoadingMore = false;
      });
    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void showEditListDialog() {
    updateListName = quotesList.name;
    updateListDesc = quotesList.description;
    updateListIsPublic = quotesList.isPublic;

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, childSetState) {
            return SimpleDialog(
              title: Text(
                'Edit ${quotesList.name}',
                overflow: TextOverflow.ellipsis,
              ),
              children: <Widget>[
                Divider(
                  thickness: 1.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: stateColors.primary),
                      hintText: quotesList.name,
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: stateColors.primary, width: 2.0),
                      ),
                    ),
                    onChanged: (newValue) {
                      updateListName = newValue;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: stateColors.primary),
                      hintText: quotesList.description,
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: stateColors.primary, width: 2.0),
                      ),
                    ),
                    onChanged: (newValue) {
                      updateListDesc = newValue;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: updateListIsPublic,
                        onChanged: (newValue) {
                          childSetState(() {
                            updateListIsPublic = newValue;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Opacity(
                          opacity: .6,
                          child: Text('Is public?'),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          updateListName = '';
                          updateListDesc = '';
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                      ),
                      RaisedButton(
                        color: stateColors.primary,
                        onPressed: () {
                          update();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  void showDeleteListDialog() {
    final name = quotesList.name;

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete $name?'),
            contentPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(top: 10.0)),
                  Divider(
                    thickness: 1.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        'This action is irreversible.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Cancel',
                  ),
                ),
              ),
              RaisedButton(
                color: Colors.red,
                onPressed: () {
                  Navigator.of(context).pop();
                  delete();
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void showQuoteSheet(Quote quote) {
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
                IconButton(
                  iconSize: 40.0,
                  tooltip: 'Delete',
                  onPressed: () {
                    Navigator.of(context).pop();
                    removeQuote(quote);
                  },
                  icon: Opacity(
                    opacity: .6,
                    child: Icon(
                      Icons.delete_outline,
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 40.0,
                  tooltip: 'Delete',
                  onPressed: () {
                    Navigator.of(context).pop();
                    shareQuote(
                      context: context,
                      quote: quote,
                    );
                  },
                  icon: Opacity(
                    opacity: .6,
                    child: Icon(
                      Icons.share,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void delete() async {
    setState(() {
      isDeletingList = true;
    });

    final success = await deleteList(
      context: context,
      id: widget.id,
    );

    setState(() {
      isDeletingList = false;
    });

    if (!success) {
      showSnack(
        context: context,
        message: 'There was and issue while deleting the list. Try again later',
        type: SnackType.error,
      );

      return;
    }

    Navigator.pop(context, true);
  }

  void removeQuote(Quote quote) async {
    int index = quotes.indexOf(quote);

    setState(() {
      quotes.removeAt(index);
    });

    final success = await removeFromList(
      context: context,
      id: widget.id,
      quote: quote,
    );

    if (!success) {
      setState(() {
        quotes.insert(index, quote);
      });

      showSnack(
        context: context,
        message:
            "Sorry, could not remove the quote from your list. Please try again later.",
        type: SnackType.error,
      );
    }
  }

  void update() async {
    final success = await updateList(
      context: context,
      id: widget.id,
      name: updateListName,
      description: updateListDesc,
      isPublic: updateListIsPublic,
      iconUrl: quotesList.iconUrl,
    );

    if (!success) {
      showSnack(
        context: context,
        message: "Sorry, could not update your list. Please try again later.",
        type: SnackType.error,
      );

      return;
    }

    setState(() {
      quotesList.name = updateListName;
      quotesList.description = updateListDesc;
      quotesList.isPublic = updateListIsPublic;
    });
  }
}
