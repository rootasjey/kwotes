import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/quotidian.dart';
import 'package:figstyle/utils/snack.dart';

/// Network interface for user's favourites.
class FavActions {
  /// Add the target quote to
  /// the current authenticated user's favourites subcollection.
  /// You only need to specify either the `quotidian` parameter or `quote` one.
  static Future<bool> add({
    BuildContext context,
    Quotidian quotidian,
    Quote quote,
  }) async {
    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        Snack.e(
          context: context,
          message: "You're not connected to add this quote to your favourites.",
        );

        return false;
      }

      String lang = quotidian != null ? quotidian.lang : quote.lang;

      if (quote == null) {
        quote = quotidian.quote;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('favourites')
          .doc(quote.id)
          .get();

      if (doc.exists) {
        return true;
      }

      final referenceId = quote.reference != null ? quote.reference.id : '';

      final referenceName = quote.reference != null ? quote.reference.name : '';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('favourites')
          .doc(quote.id)
          .set({
        'author': {
          'id': quote.author.id,
          'name': quote.author.name,
        },
        'createdAt': DateTime.now(),
        'lang': lang,
        'reference': {
          'id': referenceId,
          'name': referenceName,
        },
        'name': quote.name,
        'topics': quote.topics,
      });

      return true;
    } catch (error) {
      debugPrint(error.toString());

      Snack.e(
        context: context,
        message: 'Sorry, an error prevented the quote to be favourited.',
      );

      return false;
    }
  }

  /// Returns true if the target quote is in user's favourites.
  /// False otherwise.
  static Future<bool> isFav({
    String quoteId,
  }) async {
    final userAuth = stateUser.userAuth;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('favourites')
          .doc(quoteId)
          .get();

      return doc.exists;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// Remove the target quote from
  /// the current authenticated user's favourites subcollection.
  /// You only need to specify either the `quotidian` parameter or `quote` one.
  static Future<bool> remove({
    BuildContext context,
    Quotidian quotidian,
    Quote quote,
  }) async {
    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        Snack.e(
          context: context,
          message:
              "You're not connected to remove this quote from your favourites.",
        );

        return false;
      }

      if (quote == null) {
        quote = quotidian.quote;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('favourites')
          .doc(quote.id)
          .get();

      if (!doc.exists) {
        return true;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('favourites')
          .doc(quote.id)
          .delete();

      return true;
    } catch (error) {
      debugPrint(error.toString());

      Snack.e(
        context: context,
        message: "Sorry, the quote couldn't be unfavourited.",
      );

      return false;
    }
  }
}
