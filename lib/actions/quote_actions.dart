import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/services.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/quote.dart";

class QuoteActions {
  /// Add quote to an user's favourites
  static Future<bool> addToFavourites({
    required Quote quote,
    required userId,
  }) async {
    try {
      final DocumentSnapshotMap existingDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favourites")
          .doc(quote.id)
          .get();

      if (existingDoc.exists) {
        return true;
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favourites")
          .doc(quote.id)
          .set(quote.toMapFavourite());

      return true;
    } catch (error) {
      return false;
    }
  }

  /// Copy a quote to clipboard.
  static void copyQuote(Quote quote) {
    String textToCopy = "«${quote.name}»";

    if (quote.author.name.isNotEmpty) {
      textToCopy += " — ${quote.author.name}";
    }

    if (quote.reference.name.isNotEmpty) {
      textToCopy += " — ${quote.reference.name}";
    }

    Clipboard.setData(ClipboardData(text: textToCopy));
  }

  /// Copy a quote's url to clipboard.
  static void copyQuoteUrl(Quote quote) {
    Clipboard.setData(ClipboardData(text: "${Constants.quoteUrl}/${quote.id}"));
  }

  /// Remove a quote from an user's favourites
  static Future<bool> removeFromFavourites({
    required Quote quote,
    required userId,
  }) async {
    try {
      final existingDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favourites")
          .doc(quote.id)
          .get();

      if (!existingDoc.exists) {
        return true;
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favourites")
          .doc(quote.id)
          .delete();

      return true;
    } catch (error) {
      return false;
    }
  }
}
