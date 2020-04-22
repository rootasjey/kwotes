import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/user_quotes_list.dart';

Future<UserQuotesList> createList({
  BuildContext context,
  String name = '',
  String description = '',
  String iconUrl = '',
  bool isPublic = false,
}) async {
  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
      return null;
    }

    final docRef = await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('lists')
      .add({
        'createdAt'   : DateTime.now(),
        'description' : description,
        'name'        : name,
        'iconUrl'     : iconUrl,
        'isPublic'    : isPublic,
        'updatedAt'   : DateTime.now(),
      });

    final doc = await docRef.get();

    final data = doc.data;
    data['id'] = doc.documentID;

    return UserQuotesList.fromJSON(data);

  } catch (error) {
    debugPrint(error.toString());
    return null;
  }
}

Future<bool> deleteList({
  BuildContext context,
  String id,
}) async {

  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;
    }

    // Add a new document containing information
    // to delete the subcollection (in order to delete its documents).
    await Firestore.instance
      .collection('todelete')
      .add({
        'objectId': id,
        'path': 'users/<userId>/lists/<listId>/quotes',
        'userId': userAuth.uid,
        'target': 'list',
        'type': 'subcollection',
      });

    // Delete the quote collection doc.
    await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('lists')
      .document(id)
      .delete();

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

Future<bool> removeFromList({
  BuildContext context,
  String id,
  Quote quote,
}) async {

  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;
    }

    await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('lists')
      .document(id)
      .collection('quotes')
      .document(quote.id)
      .delete();

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}


Future<bool> updateList({
  BuildContext context,
  String id           = '',
  String iconUrl      = '',
  String name         = '',
  String description  = '',
  bool isPublic       = false,
}) async {

  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;
    }

    await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('lists')
      .document(id)
      .updateData({
        'description' : description,
        'name'        : name,
        'iconUrl'     : iconUrl,
        'isPublic'    : isPublic,
        'updatedAt'   : DateTime.now(),
      });

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}
