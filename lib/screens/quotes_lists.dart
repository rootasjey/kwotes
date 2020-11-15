import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/delete_list_dialog.dart';
import 'package:figstyle/components/edit_list_dialog.dart';
import 'package:figstyle/types/edit_list_payload.dart';
import 'package:figstyle/types/enums.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/lists.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/screens/quotes_list.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/user_quotes_list.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class QuotesLists extends StatefulWidget {
  @override
  _QuotesListsState createState() => _QuotesListsState();
}

class _QuotesListsState extends State<QuotesLists> {
  bool descending = true;
  bool hasErrors = false;
  bool hasNext = true;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool newIsPublic = false;
  bool updateListIsPublic = false;

  final pageRoute = ListsRoute;
  final scrollController = ScrollController();

  int limit = 10;

  List<UserQuotesList> userQuotesLists = [];

  DocumentSnapshot lastDoc;

  String newListName = '';
  String newListDescription = '';
  String newListIconUrl = '';

  @override
  initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateListDialog(),
        child: Icon(Icons.add),
        backgroundColor: stateColors.primary,
        foregroundColor: Colors.white,
      ),
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
    return SliverPadding(
      padding: const EdgeInsets.only(top: 24.0),
      sliver: PageAppBar(
        textTitle: 'Lists',
        textSubTitle: 'Thematic lists created by you',
        expandedHeight: 100.0,
        onTitlePressed: () {
          scrollController.animateTo(
            0,
            duration: 250.milliseconds,
            curve: Curves.easeIn,
          );
        },
        descending: descending,
        onDescendingChanged: (newDescending) {
          if (descending == newDescending) {
            return;
          }

          descending = newDescending;
          fetch();

          appStorage.setPageOrder(
            descending: newDescending,
            pageRoute: pageRoute,
          );
        },
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: LoadingAnimation(),
          ),
        ]),
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

    if (userQuotesLists.length == 0) {
      return emptyView();
    }

    return sliverQuotesList();
  }

  Widget cardItem({UserQuotesList quotesList}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 500.0,
            child: Card(
              child: InkWell(
                onTap: () async {
                  final mustRefresh = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuotesList(
                        id: quotesList.id,
                      ),
                    ),
                  );

                  if (mustRefresh == null) {
                    return;
                  }

                  if (mustRefresh) {
                    fetch();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Stack(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.list, color: Colors.white),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    quotesList.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  Opacity(
                                    opacity: .6,
                                    child: Text(
                                      quotesList.description,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'delete') {
                                showDeleteListDialog(
                                  context: context,
                                  listName: quotesList.name,
                                  onCancel: () => Navigator.of(context).pop(),
                                  onConfirm: () {
                                    Navigator.of(context).pop();
                                    deleteCurrentList(quotesList);
                                  },
                                );
                                return;
                              }

                              if (value == 'edit') {
                                showEditListDialog(
                                  context: context,
                                  listDesc: quotesList.description,
                                  listName: quotesList.name,
                                  listIsPublic: quotesList.isPublic,
                                  onCancel: () => Navigator.of(context).pop(),
                                  onConfirm: (payload) {
                                    Navigator.of(context).pop();
                                    updateSelectedList(quotesList, payload);
                                  },
                                );
                                return;
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 2.0,
          beginY: 50.0,
          child: Container(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: <Widget>[
                Opacity(
                  opacity: .8,
                  child: Icon(
                    Icons.format_list_bulleted,
                    size: 120.0,
                    color: Color(0xFFFF005C),
                  ),
                ),
                Opacity(
                  opacity: .8,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Text(
                      "You've created no list yet",
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
                      "You can create one by taping on the '+' button",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showCreateListDialog();
                  },
                  icon: Icon(
                    Icons.add,
                  ),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget sliverQuotesList() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final quoteList = userQuotesLists.elementAt(index);
            return cardItem(quotesList: quoteList);
          },
          childCount: userQuotesLists.length,
        ),
      ),
    );
  }

  void create() async {
    final quotesList = await createList(
      context: context,
      name: newListName,
      description: newListDescription,
      iconUrl: newListIconUrl,
      isPublic: newIsPublic,
    );

    if (quotesList == null) {
      showSnack(
        context: context,
        message: 'There was and issue while creating the list. Try again later',
        type: SnackType.error,
      );

      return;
    }

    setState(() {
      userQuotesLists.add(quotesList);
    });
  }

  void deleteCurrentList(UserQuotesList quotesList) async {
    int index = userQuotesLists.indexOf(quotesList);

    setState(() {
      userQuotesLists.removeAt(index);
    });

    final success = await deleteList(
      context: context,
      id: quotesList.id,
    );

    if (!success) {
      setState(() {
        userQuotesLists.insert(index, quotesList);
      });

      showSnack(
        context: context,
        message: 'There was and issue while deleting the list. Try again later',
        type: SnackType.error,
      );

      return;
    }
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      userQuotesLists.clear();

      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('lists')
          .orderBy('updatedAt', descending: descending)
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
    } catch (error) {
      debugPrint(error.toString());

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
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('lists')
          .orderBy('updatedAt', descending: descending)
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
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void showCreateListDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, childSetState) {
            return SimpleDialog(
              title: Text('Create a new list'),
              children: <Widget>[
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
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: stateColors.primary, width: 2.0),
                      ),
                    ),
                    onChanged: (newValue) {
                      newListName = newValue;
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
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: stateColors.primary, width: 2.0),
                      ),
                    ),
                    onChanged: (newValue) {
                      newListDescription = newValue;
                    },
                    onSubmitted: (_) {
                      create();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: newIsPublic,
                        onChanged: (newValue) {
                          childSetState(() {
                            newIsPublic = newValue;
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
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
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
                          create();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Create',
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

  void updateSelectedList(
    UserQuotesList quotesList,
    EditListPayload payload,
  ) async {
    final oldListDescription = quotesList.description;
    final oldListName = quotesList.name;
    final oldIsPublic = quotesList.isPublic;

    // Optimistic
    setState(() {
      quotesList.name = payload.name;
      quotesList.description = payload.description;
      quotesList.isPublic = payload.isPublic;
    });

    final success = await updateList(
      context: context,
      id: quotesList.id,
      name: payload.name,
      description: payload.description,
      isPublic: payload.isPublic,
      iconUrl: quotesList.iconUrl,
    );

    if (!success) {
      // Rollback
      setState(() {
        quotesList.description = oldListDescription;
        quotesList.name = oldListName;
        quotesList.isPublic = oldIsPublic;
      });

      showSnack(
        context: context,
        message: "Sorry, could not update your list. Please try again later.",
        type: SnackType.error,
      );

      return;
    }
  }
}
