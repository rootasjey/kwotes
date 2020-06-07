import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/drafts.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/order_button.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/sliver_app_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/types/topic_color.dart';
import 'package:memorare/utils/snack.dart';

class Drafts extends StatefulWidget {
  @override
  _DraftsState createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {
  bool hasNext        = true;
  bool hasErrors      = false;
  bool isLoading      = false;
  bool isLoadingMore  = false;
  String lang         = 'en';
  int limit           = 30;
  int order           = -1;
  bool descending     = true;

  List<TempQuote> drafts = [];
  List<TempQuote> offlineDrafts = [];
  ScrollController scrollController = ScrollController();

  var lastDoc;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body()
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
            SliverAppHeader(
              title: 'Drafts',
              rightButton: OrderButton(
                descending: descending,
                onOrderChanged: (order) {
                  setState(() {
                    descending = order;
                  });

                  fetch();
                },
              ),
            ),
            bodyListContent(),
          ],
        ),
      )
    );
  }

  Widget bodyListContent() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.only(top: 150.0),
              child:  LoadingAnimation(),
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

    if (drafts.length == 0) {
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
                  subtitle: 'You can save them when you are not ready to propose your quotes.',
                  onRefresh: () => fetch(),
                ),
              ),
            ),
          ]
        ),
      );
    }

    if (MediaQuery.of(context).size.width > 300.0) {
      return gridQuotes();
    }

    return listQuotes();
  }

  Widget listQuotes() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final draft = drafts.elementAt(index);
          final topic = draft.topics.length > 0 ? draft.topics.first : null;

          TopicColor topicColor;

          if (topic != null) {
            topicColor = appTopicsColors.find(draft.topics.first);
          } else {
            topicColor = appTopicsColors.topicsColors.first;
          }

          return InkWell(
            onTap: () => editDraft(draft),
            onLongPress: () => showQuoteSheet(draft: draft, index: index),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(padding: const EdgeInsets.only(top: 20.0),),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: <Widget>[
                      if (draft.isOffline)
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: ClipOval(
                            child: Material(
                              color: Colors.red,
                              child: InkWell(
                                splashColor: Colors.orange,
                                child: SizedBox(width: 24, height: 24,),
                                onTap: () => showOfflineHelper(),
                              ),
                            ),
                          ),
                        ),

                      Text(
                        draft.name,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                Center(
                  child: IconButton(
                    onPressed: () => showQuoteSheet(draft: draft, index: index),
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
          );
        },
        childCount: drafts.length,
      ),
    );
  }

  Widget gridQuotes() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300.0,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final draft = drafts.elementAt(index);
          final topicColor = appTopicsColors.find(draft.topics.first);

          return FadeInY(
            delay: 3.0 + index.toDouble(),
            beginY: 100.0,
            child: SizedBox(
              width: 250.0,
              height: 250.0,
              child: Card(
                child: InkWell(
                  onTap: () => editDraft(draft),
                  onLongPress: () => showQuoteSheet(draft: draft, index: index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          draft.name.length > 115 ?
                            '${draft.name.substring(0, 115)}...' : draft.name,
                          style: TextStyle(
                            fontSize: FontSize.gridItem(draft.name),
                          ),
                        ),
                      ),

                      Center(
                        child: IconButton(
                          onPressed: () => showQuoteSheet(draft: draft, index: index),
                          icon: Icon(
                            Icons.more_horiz,
                            color: topicColor != null ?
                            Color(topicColor.decimal) : stateColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: drafts.length,
      ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text(
              'Edit',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
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

      final snapColl = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('drafts')
        .orderBy('createdAt', descending: descending)
        .limit(limit)
        .getDocuments();

      if (snapColl.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapColl.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final draft = TempQuote.fromJSON(data);
        drafts.add(draft);
      });

      lastDoc = snapColl.documents.last;

      setState(() {
        isLoading = false;
        hasErrors = false;
        hasNext = snapColl.documents.length == limit;
      });

    } catch (error) {
      debugPrint(error.toString());
      hasErrors = true;
    }
  }

  Future fetchMore() async {
    if (lastDoc == null) { return; }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        throw Error();
      }

      final snapColl = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('drafts')
        .startAfterDocument(lastDoc)
        .orderBy('createdAt', descending: descending)
        .limit(limit)
        .getDocuments();

      if (snapColl.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapColl.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final draft = TempQuote.fromJSON(data);
        drafts.add(draft);
      });

      lastDoc = snapColl.documents.last;

      setState(() {
        isLoading = false;
        hasErrors = false;
        hasNext = snapColl.documents.length == limit;
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
    }
    else {
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

  void editDraft(TempQuote draft) async {
    AddQuoteInputs.isOfflineDraft = draft.isOffline;
    AddQuoteInputs.draft = draft;
    AddQuoteInputs.populateWithTempQuote(draft);

    await FluroRouter.router.navigateTo(context, AddQuoteContentRoute);

    fetch();
  }

  void showOfflineHelper() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          content: Container(
            child: Text(
              "This quote is saved in your device's offline storage. You can save it in the cloud after an edit. It can prevent data loss."
            ),
          ),
        );
      }
    );
  }

  void showQuoteSheet({TempQuote draft, int index}) {
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
                      deleteAction(draft: draft, index: index);
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
                    onPressed: () {
                      FluroRouter.router.pop(context);
                      editDraft(draft);
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
            ],
          ),
        );
      }
    );
  }
}
