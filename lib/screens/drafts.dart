import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/drafts.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/temp_quote_row_with_actions.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/screens/add_quote/steps.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/temp_quote.dart';
import 'package:figstyle/utils/app_localstorage.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class Drafts extends StatefulWidget {
  @override
  _DraftsState createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {
  bool descending = true;
  bool hasNext = true;
  bool hasErrors = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  DocumentSnapshot lastDoc;

  int limit = 30;
  int order = -1;

  ItemsLayout itemsLayout = ItemsLayout.list;

  List<TempQuote> drafts = [];
  List<TempQuote> offlineDrafts = [];

  ScrollController scrollController = ScrollController();
  final String pageRoute = DraftsRoute;

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
  }

  void initProps() {
    descending = appLocalStorage.getPageOrder(pageRoute: pageRoute);
    itemsLayout = appLocalStorage.getItemsStyle(pageRoute);
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
    return PageAppBar(
      textTitle: 'Drafts',
      textSubTitle: 'They are only visible to you',
      expandedHeight: 170.0,
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

        appLocalStorage.setPageOrder(
          descending: newDescending,
          pageRoute: pageRoute,
        );
      },
      itemsLayout: itemsLayout,
      onItemsLayoutSelected: (selectedLayout) {
        if (selectedLayout == itemsLayout) {
          return;
        }

        setState(() {
          itemsLayout = selectedLayout;
        });

        appLocalStorage.saveItemsStyle(
          pageRoute: pageRoute,
          style: selectedLayout,
        );
      },
    );
  }

  Widget body() {
    if (isLoading) {
      return loadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (drafts.length == 0) {
      return emptyView();
    }

    if (itemsLayout == ItemsLayout.list) {
      return listView();
    }

    return gridView();
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 2.0,
          beginY: 50.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: EmptyContent(
              icon: Opacity(
                opacity: .8,
                child: Icon(
                  Icons.edit,
                  size: 60.0,
                  color: Color(0xFFFF005C),
                ),
              ),
              title: 'No drafts',
              subtitle:
                  'You can save them when you are not ready to propose your quotes.',
              onRefresh: () => fetch(),
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

  Widget gridView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final draft = drafts.elementAt(index);

            return TempQuoteRowWithActions(
              componentType: ItemComponentType.card,
              isDraft: true,
              onTap: () => editDraft(draft),
              tempQuote: draft,
            );
          },
          childCount: drafts.length,
        ),
      ),
    );
  }

  Widget listView() {
    final horPadding = MediaQuery.of(context).size.width < 700.00 ? 20.0 : 70.0;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final draft = drafts.elementAt(index);

          return TempQuoteRowWithActions(
            tempQuote: draft,
            isDraft: true,
            onTap: () => editDraft(draft),
            padding: EdgeInsets.symmetric(
              horizontal: horPadding,
              vertical: 30.0,
            ),
          );
        },
        childCount: drafts.length,
      ),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: LoadingAnimation(),
        ),
      ]),
    );
  }

  Widget moreButton({int index, TempQuote draft}) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'delete') {
          deleteAction(draft: draft, index: index);
          return;
        }

        if (value == 'edit') {
          editDraft(draft);
          return;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text(
              'Edit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      drafts.clear();
    });

    try {
      fetchOffline();

      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        throw Error();
      }

      final snapColl = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('drafts')
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapColl.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapColl.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final draft = TempQuote.fromJSON(data);
        drafts.add(draft);
      });

      lastDoc = snapColl.docs.last;

      setState(() {
        isLoading = false;
        hasErrors = false;
        hasNext = snapColl.docs.length == limit;
      });
    } catch (error) {
      debugPrint(error.toString());
      hasErrors = true;
    }
  }

  Future fetchMore() async {
    if (lastDoc == null) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        throw Error();
      }

      final snapColl = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('drafts')
          .startAfterDocument(lastDoc)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapColl.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapColl.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final draft = TempQuote.fromJSON(data);
        drafts.add(draft);
      });

      lastDoc = snapColl.docs.last;

      setState(() {
        isLoading = false;
        hasErrors = false;
        hasNext = snapColl.docs.length == limit;
      });
    } catch (error) {
      debugPrint(error.toString());
      hasErrors = true;
    }
  }

  void fetchOffline() {
    final savedDrafts = getOfflineDrafts();
    drafts.addAll(savedDrafts);
  }

  void deleteAction({TempQuote draft, int index}) async {
    setState(() {
      drafts.removeAt(index);
    });

    bool success = false;

    if (draft.isOffline) {
      success = deleteOfflineDraft(createdAt: draft.createdAt.toString());
    } else {
      success = await deleteDraft(
        context: context,
        draft: draft,
      );
    }

    if (!success) {
      drafts.insert(index, draft);

      showSnack(
        context: context,
        message: "Couldn't delete the temporary quote.",
        type: SnackType.error,
      );
    }
  }

  Widget quotePopupMenuButton({
    TempQuote draft,
    int index,
    Color color,
  }) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        color: color,
      ),
      onSelected: (value) {
        if (value == 'edit') {
          editDraft(draft);
          return;
        }

        if (value == 'delete') {
          showDeleteDialog(
            draft: draft,
            index: index,
          );
          return;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            )),
        PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_sweep),
              title: Text('Delete'),
            )),
      ],
    );
  }

  void editDraft(TempQuote draft) async {
    DataQuoteInputs.isOfflineDraft = draft.isOffline;
    DataQuoteInputs.draft = draft;
    DataQuoteInputs.populateWithTempQuote(draft);

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AddQuoteSteps()));

    fetch();
  }

  void showDeleteDialog({TempQuote draft, int index}) {
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteAction(draft: draft, index: index);
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
}
