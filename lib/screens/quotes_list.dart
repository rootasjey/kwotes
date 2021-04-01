import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/delete_list_dialog.dart';
import 'package:figstyle/components/edit_list_dialog.dart';
import 'package:figstyle/components/sliver_edge_padding.dart';
import 'package:figstyle/components/sliver_empty_view.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/types/edit_list_payload.dart';
import 'package:figstyle/utils/background_op_manager.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:figstyle/utils/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/lists.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/base_page_app_bar.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/user_quotes_list.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class QuotesList extends StatefulWidget {
  final String listId;
  final void Function(bool) onResult;

  QuotesList({
    @PathParam('listId') this.listId,
    this.onResult,
  });

  @override
  _QuotesListState createState() => _QuotesListState();
}

class _QuotesListState extends State<QuotesList> {
  bool canManage = false;
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

  UserQuotesList quotesList;

  @override
  initState() {
    super.initState();
    initProps();
    fetch();
  }

  void initProps() async {
    canManage = stateUser.canManageQuotes;
    setState(() {});
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
            child: Overlay(
              initialEntries: [
                OverlayEntry(builder: (_) {
                  return CustomScrollView(
                    controller: scrollController,
                    slivers: <Widget>[
                      SliverEdgePadding(),
                      appBar(),
                      body(),
                    ],
                  );
                })
              ],
            ),
          )),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;
    double titleLeftPadding = 70.0;
    double bottomContentLeftPadding = 94.0;

    if (width < Constants.maxMobileWidth) {
      titleLeftPadding = 0.0;
      bottomContentLeftPadding = 24.0;
    }

    return BasePageAppBar(
      expandedHeight: 110.0,
      title: Padding(
        padding: EdgeInsets.only(
          left: titleLeftPadding,
        ),
        child: Row(
          children: [
            if (context.router.stack.length > 1)
              CircleButton(
                onTap: context.router.pop,
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(
                    UniconsLine.arrow_left,
                    color: stateColors.foreground,
                  ),
                ),
              ),
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
                  if (quotesList != null && quotesList.description.isNotEmpty)
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        quotesList.description,
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
          padding: EdgeInsets.only(left: bottomContentLeftPadding),
          child: Wrap(
            spacing: 20.0,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _showEditListDialog,
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(UniconsLine.edit, size: 20.0),
                ),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => showDeleteListDialog(
                  context: context,
                  listName: quotesList.name,
                  onCancel: context.router.pop,
                  onConfirm: () {
                    context.router.pop();
                    deleteCurrentList();
                  },
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(UniconsLine.trash, size: 20.0),
                ),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  primary: Colors.pink,
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
    return SliverEmptyView(
      titleString: "Empty list",
      descriptionString: "You can add some quotes from other pages",
      onRefresh: fetch,
      icon: Opacity(
        opacity: 0.8,
        child: Icon(
          UniconsLine.chat,
          size: 100.0,
        ),
      ),
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

  Widget listView() {
    final horPadding = MediaQuery.of(context).size.width < 700.00 ? 0.0 : 70.0;

    return Observer(builder: (context) {
      final isConnected = stateUser.isUserConnected;

      return SliverPadding(
        padding: const EdgeInsets.only(top: 20.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final quote = quotes.elementAt(index);

              return QuoteRowWithActions(
                quote: quote,
                quoteId: quote.quoteId,
                color: stateColors.tileBackground,
                canManage: canManage,
                isConnected: isConnected,
                key: ObjectKey(index),
                useSwipeActions: true,
                quotePageType: QuotePageType.list,
                onRemoveFromList: (_) => removeQuote(quote),
                padding: EdgeInsets.symmetric(
                  horizontal: horPadding,
                ),
              );
            },
            childCount: quotes.length,
          ),
        ),
      );
    });
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      quotes.clear();
    });

    try {
      final docListSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(stateUser.userAuth.uid)
          .collection('lists')
          .doc(widget.listId)
          .get();

      if (!docListSnap.exists) {
        Snack.e(
          context: context,
          message: "This list doesn't' exist anymore",
        );

        if (widget.onResult != null) {
          widget.onResult(true);
        }

        context.router.pop();
        return;
      }

      final data = docListSnap.data();
      data['id'] = docListSnap.id;
      quotesList = UserQuotesList.fromJSON(data);

      updateListIsPublic = quotesList.isPublic;

      final listQuotesSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(stateUser.userAuth.uid)
          .collection('lists')
          .doc(quotesList.id)
          .collection('quotes')
          .limit(limit)
          .get();

      if (listQuotesSnap.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      listQuotesSnap.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        hasNext = listQuotesSnap.docs.length == limit;
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
    setState(() => isLoadingMore = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(stateUser.userAuth.uid)
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

  void deleteCurrentList() async {
    FlashHelper.showProgress(
      context,
      title: "Delete",
      progressId: quotesList.id,
      message: "Deleting the list ${quotesList.name}...",
      icon: Icon(UniconsLine.trash, color: Colors.pink),
      duration: 60.seconds,
    );

    BackgroundOpManager.setContext(context);
    ListsActions.delete(id: widget.listId);

    if (context.router.stack.length > 1) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (widget.onResult != null) {
          widget.onResult(true);
        }

        context.router.pop();
      });
      return;
    }

    context.router.root.push(
      DashboardPageRoute(
        children: [QuotesListsDeepRoute()],
      ),
    );
  }

  void removeQuote(Quote quote) async {
    int index = quotes.indexOf(quote);

    setState(() {
      quotes.removeAt(index);
    });

    final success = await ListsActions.removeFrom(
      id: widget.listId,
      quote: quote,
    );

    if (!success) {
      setState(() {
        quotes.insert(index, quote);
      });

      Snack.e(
        context: context,
        message: "Sorry, could not remove the quote from your list."
            " Please try again later.",
      );
    }
  }

  void updateCurrentList(EditListPayload payload) async {
    final success = await ListsActions.update(
      id: widget.listId,
      name: payload.name,
      description: payload.description,
      isPublic: payload.isPublic,
      iconUrl: quotesList.iconUrl,
    );

    if (!success) {
      Snack.e(
        context: context,
        message: "Sorry, we couldn't update your list. Please try again later.",
      );

      return;
    }

    setState(() {
      quotesList.name = payload.name;
      quotesList.description = payload.description;
      quotesList.isPublic = payload.isPublic;
    });
  }

  Future _showEditListDialog() {
    return showEditListDialog(
      context: context,
      listDesc: quotesList.description,
      listName: quotesList.name,
      listIsPublic: quotesList.isPublic,
      subtitle: quotesList.name,
      onCancel: context.router.pop,
      onConfirm: (payload) {
        context.router.pop();
        updateCurrentList(payload);
      },
      onNameSubmitted: (payload) {
        context.router.pop();
        updateCurrentList(payload);
      },
      onDescriptionSubmitted: (payload) {
        context.router.pop();
        updateCurrentList(payload);
      },
    );
  }
}
