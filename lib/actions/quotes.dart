import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:memorare/types/quote.dart';

Future<bool> deleteQuote({Quote quote}) async {
  try {
    await Firestore.instance
      .collection('quotes')
      .document(quote.id)
      .delete();

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}
