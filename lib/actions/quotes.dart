import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/types/temp_quote.dart';

Future<bool> deleteQuote({Quote quote}) async {
  try {
    await FirebaseFirestore.instance
        .collection('quotes')
        .doc(quote.id)
        .delete();

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
    // 1.Create or get reference if any.
    final reference = await createOrGetReference(tempQuote);
    final referencesArray = [];

    // 2.Create or get author if any.
    final author = await createOrGetAuthor(tempQuote, reference);

    if (reference.id.isNotEmpty) {
      referencesArray.add({
        'id': reference.id,
        'name': reference.name,
      });
    }

    // 3.Create topics map.
    final topics = createTopicsMap(tempQuote);

    // 5.Format data and add new quote.
    final addedQuote =
        await FirebaseFirestore.instance.collection('quotes').add({
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

    // 6.Create comment if any.
    await createComments(
      quoteId: addedQuote.id,
      tempQuote: tempQuote,
      uid: uid,
    );

    // 7.Delete temp quote.
    await FirebaseFirestore.instance
        .collection('tempquotes')
        .doc(tempQuote.id)
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
    FirebaseFirestore.instance.collection('comments').add({
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

Future<Author> createOrGetAuthor(
    TempQuote tempQuote, Reference reference) async {
  final author = tempQuote.author;

  // Anonymous author
  if (author.name.isEmpty && author.id.isEmpty) {
    final anonymousSnap = await FirebaseFirestore.instance
        .collection('authors')
        .where('name', isEqualTo: 'Anonymous')
        .get();

    if (anonymousSnap.docs.isEmpty) {
      throw ErrorDescription('Document not found for Anonymous author.');
    }

    final match = anonymousSnap.docs.first;

    return Author(
      id: match.id,
      name: 'Anonymous',
    );
  }

  if (author.id.isNotEmpty) {
    return Author(
      id: author.id,
      name: author.name,
    );
  }

  final newAuthor = await FirebaseFirestore.instance.collection('authors').add({
    'born': {
      'beforeJC': author.born.beforeJC,
      'city': author.born.city,
      'country': author.born.country,
      'date': author.born.date,
    },
    'createdAt': DateTime.now(),
    'death': {
      'beforeJC': author.death.beforeJC,
      'city': author.death.city,
      'country': author.death.country,
      'date': author.death.date,
    },
    'fromReference': {
      'id': author.isFictional ? reference.id : '',
    },
    'isFictional': author.isFictional,
    'job': author.job,
    'jobLang': {},
    'name': author.name,
    'summary': author.summary,
    'summaryLang': {},
    'updatedAt': DateTime.now(),
    'urls': {
      'amazon': author.urls.amazon,
      'facebook': author.urls.facebook,
      'image': author.urls.image,
      'instagram': author.urls.instagram,
      'netflix': author.urls.netflix,
      'primeVideo': author.urls.primeVideo,
      'twitch': author.urls.twitch,
      'twitter': author.urls.twitter,
      'website': author.urls.website,
      'wikipedia': author.urls.wikipedia,
      'youtube': author.urls.youtube,
    }
  });

  return Author(
    id: newAuthor.id,
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

  final newReference =
      await FirebaseFirestore.instance.collection('references').add({
    'createdAt': DateTime.now(),
    'lang': reference.lang,
    'linkedRefs': [],
    'name': reference.name,
    'release': {
      'original': reference.release.original,
      'beforeJC': reference.release.beforeJC,
    },
    'summary': reference.summary,
    'type': {
      'primary': reference.type.primary,
      'secondary': reference.type.secondary,
    },
    'updatedAt': DateTime.now(),
    'urls': {
      'amazon': reference.urls.amazon,
      'facebook': reference.urls.facebook,
      'image': reference.urls.image,
      'instagram': reference.urls.instagram,
      'netflix': reference.urls.netflix,
      'primeVideo': reference.urls.primeVideo,
      'twitch': reference.urls.twitch,
      'twitter': reference.urls.twitter,
      'website': reference.urls.website,
      'wikipedia': reference.urls.wikipedia,
      'youtube': reference.urls.youtube,
    },
  });

  return Reference(
    id: newReference.id,
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
