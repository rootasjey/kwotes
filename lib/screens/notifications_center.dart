import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fig_style/components/data_quote_inputs.dart';
import 'package:fig_style/components/empty_content.dart';
import 'package:fig_style/components/error_container.dart';
import 'package:fig_style/components/fade_in_y.dart';
import 'package:fig_style/components/page_app_bar.dart';
import 'package:fig_style/components/sliver_loading_view.dart';
import 'package:fig_style/screens/add_quote/steps.dart';
import 'package:fig_style/screens/signin.dart';
import 'package:fig_style/state/colors.dart';
import 'package:fig_style/state/user.dart';
import 'package:fig_style/types/app_notification.dart';
import 'package:fig_style/types/temp_quote.dart';
import 'package:fig_style/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';

class NotificationsCenter extends StatefulWidget {
  final ScrollController scrollController;

  NotificationsCenter({this.scrollController});

  @override
  _NotificationsCenterState createState() => _NotificationsCenterState();
}

class _NotificationsCenterState extends State<NotificationsCenter> {
  bool descending = true;
  bool hasNext = true;
  bool hasErrors = false;
  bool isFabVisible = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  DocumentSnapshot lastDoc;

  final limit = 30;

  List<AppNotification> notificationsList = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                widget.scrollController.animateTo(
                  0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: stateColors.primary,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotif) {
          // FAB visibility
          if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
            setState(() {
              isFabVisible = false;
            });
          } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
            setState(() {
              isFabVisible = true;
            });
          }

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
          controller: widget.scrollController,
          slivers: [
            appBar(),
            body(),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return PageAppBar(
      textTitle: "Notifications",
      showCloseButton: true,
      onTitlePressed: () {
        widget.scrollController.animateTo(
          0,
          duration: 250.milliseconds,
          curve: Curves.easeIn,
        );
      },
    );
  }

  Widget body() {
    if (isLoading) {
      return SliverLoadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (notificationsList.length == 0) {
      return emptyView();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24.0),
      sliver: listView(),
    );
  }

  Widget listView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final notif = notificationsList.elementAt(index);
          return notificationItem(notif, index);
        },
        childCount: notificationsList.length,
      ),
    );
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 0.milliseconds,
          beginY: 50.0,
          child: EmptyContent(
            icon: Opacity(
              opacity: .8,
              child: Icon(
                Icons.notifications_none,
                size: 120.0,
                color: Color(0xFFFF005C),
              ),
            ),
            title: "You have no notifications",
            subtitle:
                "You can receive some when your quotes in validation is accepted or rejected",
            onRefresh: () => fetch(),
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

  Widget notificationItem(AppNotification notif, int index) {
    return SwipeActionCell(
      key: ObjectKey(index),
      performsFirstActionWithFullSwipe: true,
      trailingActions: [
        SwipeAction(
          title: "Delete",
          icon: Icon(Icons.delete_outline, color: Colors.white),
          color: stateColors.deletion,
          onTap: (CompletionHandler handler) {
            handler(false);
            deleteNotification(notif, index);
          },
        ),
      ],
      child: SizedBox(
        width: 400.0,
        child: Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () => onTap(notif, index),
            onLongPress: () => onLongPress(notif, index),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notif.title != null && notif.title.isNotEmpty)
                        Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: notif.isRead ? null : stateColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Opacity(
                          opacity: 0.7,
                          child: Text(
                            notif.body,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          Jiffy(notif.createdAt).fromNow(),
                          style: TextStyle(
                            fontSize: 16.0,
                            color: notif.isRead ? null : stateColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notif.isRead)
                  Positioned(
                    top: 20.0,
                    right: 20.0,
                    child: CircleAvatar(
                      radius: 5.0,
                      backgroundColor: stateColors.secondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      hasNext = true;
      notificationsList.clear();
    });

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => Signin(),
          ),
        );

        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('notifications')
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final notification = AppNotification.fromJSON(data);
        notificationsList.add(notification);
      });

      setState(() {
        hasNext = snapshot.size == limit;
        lastDoc = snapshot.docs.last;
        isLoading = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        hasErrors = true;
        hasNext = false;
        isLoading = false;
      });
    }
  }

  Future fetchMore() async {
    if (!hasNext || lastDoc == null) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => Signin()));

        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('notifications')
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .startAfterDocument(lastDoc)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final notification = AppNotification.fromJSON(data);
        notificationsList.add(notification);
      });

      setState(() {
        hasNext = snapshot.size == limit;
        lastDoc = snapshot.docs.last;
        isLoadingMore = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        hasNext = false;
        isLoadingMore = false;
      });
    }
  }

  void deleteNotification(AppNotification notif, int index) async {
    setState(() {
      notificationsList.removeAt(index);
    });

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => Signin()));

        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('notifications')
          .doc(notif.id)
          .delete();
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        notificationsList.insert(index, notif);
      });
    }
  }

  void onLongPress(AppNotification notif, int index) {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  tileColor: stateColors.deletion,
                  title: Text('Delete'),
                  trailing: Icon(Icons.delete_outline),
                  onTap: () {
                    Navigator.of(context).pop();
                    deleteNotification(notif, index);
                  },
                ),
              ],
            ),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(12.0),
              child: child,
            ),
          ),
        );
      },
    );
  }

  void onTap(AppNotification notif, int index) async {
    markRead(notif);

    if (notif.subject != 'tempQuotes') {
      return;
    }

    final path = notif.path;
    final tempQuoteId = path.substring(path.lastIndexOf('/'));

    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tempquotes')
          .doc(tempQuoteId)
          .get();

      if (!snapshot.exists) {
        Snack.e(
          context: context,
          message:
              "Sorry, we couldn't get the quote in validation. It may have been deleted.",
        );

        return;
      }

      setState(() => isLoading = false);

      final data = snapshot.data();
      data['id'] = snapshot.id;
      final tempQuote = TempQuote.fromJSON(data);

      DataQuoteInputs.populateWithTempQuote(tempQuote);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddQuoteSteps(),
        ),
      );
    } catch (error) {
      debugPrint(error.toString());

      Snack.e(
        context: context,
        message:
            "Sorry, there was an error while navigating to notification's target.",
      );
    }
  }

  void markRead(AppNotification notif) async {
    if (notif.isRead) {
      return;
    }

    setState(() => notif.isRead = true);

    try {
      final userAuth = stateUser.userAuth;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .get();

      if (!userSnapshot.exists) {
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('notifications')
          .doc(notif.id)
          .update({
        'isRead': true,
      });

      final userData = userSnapshot.data();

      int unread = userData['stats']['notifications']['unread'];
      unread = max(unread - 1, 0);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .update({
        'stats.notifications.unread': unread,
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
