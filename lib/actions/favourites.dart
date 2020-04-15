import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/snack.dart';

/// Add the target quote to the current authenticated user's favourites subcollection.
/// You only need to specify either the `quotidian` parameter or `quote` one.
Future<bool> addToFavourites({
  BuildContext context,
  Quotidian quotidian,
  Quote quote,
}) async {

  try {
    final userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth == null) {
      showSnack(
        context: context,
        message: "You're not connected to add this quote to your favourites.",
        type: SnackType.error,
      );

      return false;
    }

    String lang = quotidian != null ?
      quotidian.lang : quote.lang;

    if (quote == null) {
      quote = quotidian.quote;
    }

    final doc = await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('favourites')
      .document(quote.id)
      .get();

    if (doc.exists) {
      return true;
    }

    await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('favourites')
      .document(quote.id)
      .setData({
        'author'        : {
          'id'          : quote.author.id,
          'name'        : quote.author.name,
        },
        'createdAt'     : DateTime.now(),
        'lang'          : lang,
        'mainReference' : {
          'id'          : quote.mainReference.id,
          'name'        : quote.mainReference.name,
        },
        'name'          : quote.name,
        'quoteId'       : quote.id,
        'topics'        : quote.topics,
      });

    return true;

  } catch (error) {
    debugPrint(error.toString());

    showSnack(
      context: context,
      message: 'Sorry, an error prevented the quote to be favourited.',
      type: SnackType.error,
    );

    return false;
  }
}

/// Returns true if the target quote is in user's favourites.
/// False otherwise.
Future<bool> isFavourite({
  String quoteId,
  String userUid,
}) async {

  try {
    final doc = await Firestore.instance
      .collection('users')
      .document(userUid)
      .collection('favourites')
      .document(quoteId)
      .get();

    return doc.exists;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

/// Remove the target quote from the current authenticated user's favourites subcollection.
/// You only need to specify either the `quotidian` parameter or `quote` one.
Future<bool> removeFromFavourites({
  BuildContext context,
  Quotidian quotidian,
  Quote quote,
}) async {

  try {
    final userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth == null) {
      showSnack(
        context: context,
        message: "You're not connected to remove this quote from your favourites.",
        type: SnackType.error,
      );

      return false;
    }

    if (quote == null) {
      quote = quotidian.quote;
    }

    final doc = await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('favourites')
      .document(quote.id)
      .get();

    if (!doc.exists) {
      return true;
    }

    await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('favourites')
      .document(quote.id)
      .delete();

    return true;

  } catch (error) {
    debugPrint(error.toString());

    showSnack(
      context: context,
      message: "Sorry, the quote couldn't be unfavourited.",
      type: SnackType.error,
    );

    return false;
  }
}
