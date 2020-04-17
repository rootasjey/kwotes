import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/types/temp_quote.dart';

Future<bool> deleteTempQuote({
  BuildContext context,
  TempQuote tempQuote,
}) async {

  try {
    await Firestore.instance
      .collection('tempquotes')
      .document(tempQuote.id)
      .delete();

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}
