import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotidian.dart';

/// Add the target quote to the current authenticated user's favourites subcollection.
/// You only need to specify either the `quotidian` parameter or `quote` one.
Future addToFavourites({
  BuildContext context,
  Quotidian quotidian,
  Quote quote,
}) async {

  try {

    final userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth == null) {
      Flushbar(
        backgroundColor: Colors.red,
        message: "You're not connected to add this quote to your favourites.",
      )..show(context);

      return;
    }

    String lang = quotidian != null ?
      quotidian.lang : quote.lang;

    if (quote == null) {
      quote = quotidian.quote;
    }

    final doc = await FirestoreApp.instance
      .collection('users')
      .doc(userAuth.uid)
      .collection('favourites')
      .doc(quote.id)
      .get();

    if (doc.exists) {
      return;
    }

    await FirestoreApp.instance
      .collection('users')
      .doc(userAuth.uid)
      .collection('favourites')
      .doc(quote.id)
      .set({
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

    Flushbar(
      duration: Duration(seconds: 3),
      backgroundColor: Colors.green,
      messageText: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(Icons.check_circle, color: Colors.white,),
          ),

          Text(
            "The quote has been added to your favourites.",
            style: TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    )..show(context);

  } catch (error) {
    debugPrint(error.toString());

    Flushbar(
      duration: Duration(seconds: 3),
      backgroundColor: Colors.red,
      messageText: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(Icons.error, color: Colors.white,),
          ),

          Text(
            "Sorry, we couldn't add the quote to your favourites.",
            style: TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    )..show(context);
  }
}
