import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/temp_quote.dart';

Future<bool> deleteQuote({Quote quote}) async {
  try {
    await Firestore.instance.collection('quotes').document(quote.id).delete();

    return true;
  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

Future<bool> validateTempQuote({
  TempQuote tempQuote,
  String uid,
}) async {
  try {
    // 2.Create or get author if any
    final author = await createOrGetAuthor(tempQuote);

    // 3.Create or get reference if any
    final reference = await createOrGetReference(tempQuote);
    final referencesArray = [];

    if (reference.id.isNotEmpty) {
      referencesArray.add({
        'id': reference.id,
        'name': reference.name,
      });
    }

    // 4.Create topics map
    final topics = createTopicsMap(tempQuote);

    // 5.Format data and add new quote
    final docQuote = await Firestore.instance
    .collection('quotes')
    .add({
      'author': {
        'id': author.id,
        'name': author.name,
      },
      'createdAt': DateTime.now(),
      'lang': tempQuote.lang,
      'links': [],
      'mainReference': {
        'id': reference.id,
        'name': reference.name,
      },
      'name': tempQuote.name,
      'references': referencesArray,
      'region': tempQuote.region,
      'stats': {
        'likes': 0,
        'shares': 0,
      },
      'topics': topics,
      'updatedAt': DateTime.now(),
      'user': {
        'id': uid,
      }
    });

    // 6.Create comment if any
    await createComments(
      quoteId: docQuote.documentID,
      tempQuote: tempQuote,
      uid: uid,
    );

    // 7.Delete temp quote
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

Future createComments({
  TempQuote tempQuote,
  String quoteId,
  String uid,
}) async {

  final tempComments = tempQuote.comments;

  tempComments.forEach((tempComment) {
    Firestore.instance.collection('comments').add({
      'commentId': '',
      'createdAt': DateTime.now(),
      'level': 0,
      'name': tempComment,
      'quoteId': quoteId,
      'updatedAt': DateTime.now(),
      'user': {
        'id': uid,
      },
    });
  });
}

Future<Author> createOrGetAuthor(TempQuote tempQuote) async {
  final author = tempQuote.author;

  // Anonymous author
  if (author.name.isEmpty) {
    final anonymousSnap = await Firestore.instance
        .collection('authors')
        .where('name', isEqualTo: 'Anonymous')
        .getDocuments();

    if (anonymousSnap.documents.isEmpty) {
      throw ErrorDescription('Document not found for Anonymous author.');
    }

    final firstDoc = anonymousSnap.documents.first;

    return Author(
      id: firstDoc.documentID,
      name: 'Anonymous',
    );
  }

  if (author.id.isNotEmpty) {
    return Author(
      id: author.id,
      name: author.name,
    );
  }

  final existingSnapshot = await Firestore.instance
      .collection('authors')
      .where('name', isEqualTo: author.name)
      .getDocuments();

  if (existingSnapshot.documents.isNotEmpty) {
    final existingAuthor = existingSnapshot.documents.first;
    final data = existingAuthor.data;

    return Author(
      id: existingAuthor.documentID,
      name: data['name'],
    );
  }

  final newAuthor = await Firestore.instance
  .collection('authors')
  .add({
    'createdAt': DateTime.now(),
    'job': author.job,
    'jobLang': {},
    'name': author.name,
    'summary': author.summary,
    'summaryLang': {},
    'updatedAt': DateTime.now(),
    'urls': {
      'amazon'    : author.urls.amazon,
      'facebook'  : author.urls.facebook,
      'image'     : author.urls.image,
      'netflix'   : author.urls.netflix,
      'primeVideo': author.urls.primeVideo,
      'twitch'    : author.urls.twitch,
      'twitter'   : author.urls.twitter,
      'website'   : author.urls.website,
      'wikipedia' : author.urls.wikipedia,
      'youtube'   : author.urls.youtube,
    }
  });

  return Author(
    id: newAuthor.documentID,
    name: author.name,
  );
}

Future<Reference> createOrGetReference(TempQuote tempQuote) async {
  if (tempQuote.references.length == 0) {
    return Reference();
  }

  final reference = tempQuote.references.first;

  if (reference.id.isNotEmpty) {
    return Reference(
      id: reference.id,
      name: reference.name,
    );
  }

  final existingSnapshot = await Firestore.instance
      .collection('references')
      .where('name', isEqualTo: reference.name)
      .getDocuments();

  if (existingSnapshot.documents.isNotEmpty) {
    final existingRef = existingSnapshot.documents.first;
    final data = existingRef.data;

    return Reference(
      id: existingRef.documentID,
      name: data['name'],
    );
  }

  final newReference = await Firestore.instance.collection('references').add({
    'createdAt': DateTime.now(),
    'lang': reference.lang,
    'linkedRefs': [],
    'name': reference.name,
    'summary': reference.summary,
    'type': {
      'primary': reference.type.primary,
      'secondary': reference.type.secondary,
    },
    'updatedAt': DateTime.now(),
    'urls': {
      'amazon'      : reference.urls.amazon,
      'facebook'    : reference.urls.facebook,
      'image'       : reference.urls.image,
      'netflix'     : reference.urls.netflix,
      'primeVideo'  : reference.urls.primeVideo,
      'twitch'      : reference.urls.twitch,
      'twitter'     : reference.urls.twitter,
      'website'     : reference.urls.website,
      'wikipedia'   : reference.urls.wikipedia,
      'youtube'     : reference.urls.youtube,
    },
  });

  return Reference(
    id: newReference.documentID,
    name: reference.name,
  );
}

Map<String, dynamic> createTopicsMap(TempQuote tempQuote) {
  final Map<String, dynamic> topicsMap = {};

  tempQuote.topics.forEach((topic) {
    topicsMap[topic] = true;
  });

  return topicsMap;
}
