import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/user_quotes_list.dart';

Future<UserQuotesList> createList({
  @required BuildContext context,
  String name = '',
  String description = '',
  String iconUrl = '',
  bool isPublic = false,
}) async {
  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Signin()),
      );

      return null;
    }

    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .add({
      'createdAt': DateTime.now(),
      'description': description,
      'name': name,
      'itemsCount': 0,
      'iconUrl': iconUrl,
      'isPublic': isPublic,
      'updatedAt': DateTime.now(),
    });

    final doc = await docRef.get();

    final data = doc.data();
    data['id'] = doc.id;

    return UserQuotesList.fromJSON(data);
  } catch (error) {
    debugPrint(error.toString());
    return null;
  }
}

Future<bool> deleteList({
  @required BuildContext context,
  @required String id,
}) async {
  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Signin()),
      );

      return false;
    }

    // Add a new document containing information
    // to delete the subcollection (in order to delete its documents).
    await FirebaseFirestore.instance.collection('todelete').add({
      'objectId': id,
      'path': 'users/<userId>/lists/<listId>/quotes',
      'userId': userAuth.uid,
      'target': 'list',
      'type': 'subcollection',
    });

    // Delete the quote collection doc.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .doc(id)
        .delete();

    return true;
  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

Future<bool> removeFromList({
  @required BuildContext context,
  @required String id,
  @required Quote quote,
}) async {
  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Signin()),
      );

      return false;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .doc(id)
        .collection('quotes')
        .doc(quote.id)
        .delete();

    return true;
  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

Future<bool> updateList({
  @required BuildContext context,
  String id = '',
  String iconUrl = '',
  String name = '',
  String description = '',
  bool isPublic = false,
}) async {
  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Signin()),
      );

      return false;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .doc(id)
        .update({
      'description': description,
      'name': name,
      'iconUrl': iconUrl,
      'isPublic': isPublic,
      'updatedAt': DateTime.now(),
    });

    return true;
  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}
