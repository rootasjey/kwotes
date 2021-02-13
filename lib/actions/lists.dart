import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/state/user.dart';
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
    final userAuth = stateUser.userAuth;

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
    final userAuth = stateUser.userAuth;
    final idToken = await userAuth.getIdToken();

    final callable = CloudFunctions(
      app: Firebase.app(),
      region: 'europe-west3',
    ).getHttpsCallable(
      functionName: 'lists-deleteList',
    );

    final response = await callable.call({
      'listId': id,
      'idToken': idToken,
    });

    final responseData = response.data;
    final bool success = responseData['success'];
    return success;
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
    final userAuth = stateUser.userAuth;

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
    final userAuth = stateUser.userAuth;

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
