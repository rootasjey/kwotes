import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/temp_quote.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:figstyle/utils/storage_keys.dart';
import 'package:flutter/material.dart';

class RejectTempQuote extends StatefulWidget {
  final TempQuote tempQuote;
  final ScrollController scrollController;

  RejectTempQuote({
    this.scrollController,
    @required this.tempQuote,
  });

  @override
  _RejectTempQuoteState createState() => _RejectTempQuoteState();
}

class _RejectTempQuoteState extends State<RejectTempQuote> {
  bool sendPushNotification = false;

  final reasonController = TextEditingController();
  final reasonFocusNode = FocusNode();

  String notifBody = '';
  String notifTitle = "Your quote need some attention";
  String username = '';

  @override
  void initState() {
    super.initState();
    initProps();
    fetchUser();
  }

  @override
  void dispose() {
    reasonController.dispose();
    reasonFocusNode.dispose();
    super.dispose();
  }

  void initProps() {
    sendPushNotification =
        appStorage.getBool(StorageKeys.sendPushOnNewNotification) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: sendReject,
        label: Text(
          "Send rejection",
        ),
        icon: Icon(Icons.send),
      ),
      body: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          appBar(),
          body(),
        ],
      ),
    );
  }

  Widget appBar() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 16.0),
      sliver: PageAppBar(
        textTitle: "Reject quote",
        textSubTitle: "Explain why this quote doesn't pass validation",
        expandedHeight: 90.0,
        showNavBackIcon: false,
        showCloseButton: true,
      ),
    );
  }

  Widget body() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              pageDescription(),
              reasonTextInput(),
              notificationToggle(),
              // buttonValidation(),
            ],
          ),
        ]),
      ),
    );
  }

  Widget pageDescription() {
    return Container(
      width: 450.0,
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              username,
              style: TextStyle(
                color: stateColors.primary,
              ),
            ),
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              "This quote will be rejected with the reason specified. "
              "You can choose to send a push notification a long the way.",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget reasonTextInput() {
    return Container(
      width: 450.0,
      padding: const EdgeInsets.only(top: 60.0),
      child: TextField(
        autofocus: true,
        controller: reasonController,
        focusNode: reasonFocusNode,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          icon: Icon(Icons.message),
          labelText: "Reason",
          hintText: "Your quote has a dummy content",
          alignLabelWithHint: true,
        ),
        minLines: 1,
        maxLines: 1,
        style: TextStyle(
          fontSize: 20.0,
        ),
        onChanged: (newValue) {
          notifBody = newValue;
        },
      ),
    );
  }

  Widget notificationToggle() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: CheckboxListTile(
        title: Text("Send push notification"),
        subtitle:
            Text("This user will receive a notification on all their devices"),
        value: sendPushNotification,
        onChanged: (newValue) {
          setState(() {
            sendPushNotification = newValue;
          });

          appStorage.setBool(StorageKeys.sendPushOnNewNotification, newValue);
        },
      ),
    );
  }

  Widget buttonValidation() {
    return OutlinedButton.icon(
      onPressed: () => sendReject(),
      icon: Icon(Icons.send),
      label: Text(
        "Send rejection",
      ),
    );
  }

  void fetchUser() async {
    try {
      final userId = widget.tempQuote.user.id;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!snapshot.exists) {
        showSnack(
          context: context,
          message: "This temporary quote's author doesn't exist anymore.",
          type: SnackType.error,
        );
        return;
      }

      final userData = snapshot.data();

      setState(() {
        username = userData['name'];
      });
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  void sendReject() async {
    final tempQuote = widget.tempQuote;
    final userId = tempQuote.user.id;

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => Signin()),
        );

        return;
      }

      await FirebaseFirestore.instance
          .collection('tempquotes')
          .doc(tempQuote.id)
          .update({
        'validation': {
          'comment': {
            'name': notifBody,
            'moderatorId': userAuth.uid,
          },
          'status': 'rejected',
          'updatedAt': DateTime.now(),
        },
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        "body": notifBody,
        "title": notifTitle,
        "subject": "tempQuotes",
        "path": "/edit/tempquote/${tempQuote.id}",
        "isRead": false,
        "sendPushNotification": sendPushNotification,
        "createdAt": DateTime.now(),
        "updatedAt": DateTime.now(),
      });

      Navigator.of(context).pop();
    } catch (error) {
      debugPrint(error.toString());

      showSnack(
        context: context,
        message: "Couldn't send notification. Please try again later.",
        type: SnackType.error,
      );
    }
  }
}
