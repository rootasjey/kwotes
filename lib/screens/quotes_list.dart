import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/delete_list_dialog.dart';
import 'package:figstyle/components/edit_list_dialog.dart';
import 'package:figstyle/types/edit_list_payload.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/lists.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/base_page_app_bar.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/user_quotes_list.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class QuotesList extends StatefulWidget {
  final String id;

  QuotesList({
    @required this.id,
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
    canManage = await canUserManage();
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
          padding: EdgeInsets.only(left: bottomContentLeftPadding),
          child: Wrap(
            spacing: 20.0,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () => showEditListDialog(
                  context: context,
                  listDesc: quotesList.description,
                  listName: quotesList.name,
                  listIsPublic: quotesList.isPublic,
                  subtitle: quotesList.name,
                  onCancel: () => Navigator.of(context).pop(),
                  onConfirm: (payload) {
                    Navigator.of(context).pop();
                    updateCurrentList(payload);
                  },
                ),
                icon: Icon(Icons.edit),
                label: Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: () => showDeleteListDialog(
                  context: context,
                  listName: quotesList.name,
                  onCancel: () => Navigator.of(context).pop(),
                  onConfirm: () {
                    Navigator.of(context).pop();
                    deleteCurrentList();
                  },
                ),
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
            showDeleteListDialog(
              context: context,
              listName: quotesList.name,
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () {
                Navigator.of(context).pop();
                deleteCurrentList();
              },
            );
            break;
          case 'edit':
            showEditListDialog(
              context: context,
              listDesc: quotesList.description,
              listName: quotesList.name,
              listIsPublic: quotesList.isPublic,
              subtitle: quotesList.name,
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: (payload) {
                Navigator.of(context).pop();
                updateCurrentList(payload);
              },
            );
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
                color: stateColors.appBackground,
                canManage: canManage,
                isConnected: isConnected,
                key: ObjectKey(index),
                useSwipeActions: true,
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
    });
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      quotes.clear();

      final userAuth = await stateUser.userAuth;

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
      final userAuth = await stateUser.userAuth;

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

  void deleteCurrentList() async {
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

  void updateCurrentList(EditListPayload payload) async {
    final success = await updateList(
      context: context,
      id: widget.id,
      name: payload.name,
      description: payload.description,
      isPublic: payload.isPublic,
      iconUrl: quotesList.iconUrl,
    );

    if (!success) {
      showSnack(
        context: context,
        message: "Sorry, we couldn't update your list. Please try again later.",
        type: SnackType.error,
      );

      return;
    }

    setState(() {
      quotesList.name = payload.name;
      quotesList.description = payload.description;
      quotesList.isPublic = payload.isPublic;
    });
  }
}
