import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/snack.dart';

Future addNewTempQuote({
  List<String> comments,
  List<Map<String, dynamic>> references,
  Map<String, bool> topics,
}) async {

  final userAuth = await userState.userAuth;

  await Firestore.instance
    .collection('tempquotes')
    .add({
      'author'        : {
        'id'          : AddQuoteInputs.author.id,
        'job'         : AddQuoteInputs.author.job,
        'jobLang'     : {},
        'name'        : AddQuoteInputs.author.name,
        'summary'     : AddQuoteInputs.author.summary,
        'summaryLang' : {},
        'updatedAt'   : DateTime.now(),
        'urls': {
          'affiliate' : AddQuoteInputs.author.urls.affiliate,
          'amazon'    : AddQuoteInputs.author.urls.amazon,
          'facebook'  : AddQuoteInputs.author.urls.facebook,
          'image'     : AddQuoteInputs.author.urls.image,
          'netflix'   : AddQuoteInputs.author.urls.netflix,
          'primeVideo': AddQuoteInputs.author.urls.primeVideo,
          'twitch'    : AddQuoteInputs.author.urls.twitch,
          'twitter'   : AddQuoteInputs.author.urls.twitter,
          'website'   : AddQuoteInputs.author.urls.website,
          'wikipedia' : AddQuoteInputs.author.urls.wikipedia,
          'youTube'   : AddQuoteInputs.author.urls.youTube,
        }
      },
      'comments'      : comments,
      'createdAt'     : DateTime.now(),
      'lang'          : AddQuoteInputs.quote.lang,
      'name'          : AddQuoteInputs.quote.name,
      'mainReference' : {
        'id'  : AddQuoteInputs.reference.id,
        'name': AddQuoteInputs.reference.name,
      },
      'references'    : references,
      'region'        : AddQuoteInputs.region,
      'topics'        : topics,
      'user': {
        'id': userAuth.uid,
      },
      'updatedAt'     : DateTime.now(),
      'validation'    : {
        'comment'     : {
          'name'      : '',
          'updatedAt' : DateTime.now(),
        },
        'status'      : 'proposed',
        'updatedAt'   : DateTime.now(),
      }
    });
}

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

Future<bool> proposeQuote({
  BuildContext context,
}) async {
  if (AddQuoteInputs.quote.name.isEmpty) {
    showSnack(
      context: context,
      message: "The quote's content cannot be empty.",
      type: SnackType.error,
    );

    return false;
  }

  if (AddQuoteInputs.quote.topics.length == 0) {
    showSnack(
      context: context,
      message: 'You must select at least 1 topics for the quote.',
      type: SnackType.error,
    );

    return false;
  }

  final comments = List<String>();

  if (AddQuoteInputs.comment.isNotEmpty) {
    comments.add(AddQuoteInputs.comment);
  }

  final references = formatReferences();

  final topics = Map<String, bool>();

  AddQuoteInputs.quote.topics.forEach((topic) {
    topics[topic] = true;
  });

  try {
    final userAuth = await userState.userAuth;

    final user = await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .get();

    int today = user.data['quota']['today'];
    today++;

    int proposed = user.data['stats']['proposed'];
    proposed++;

    // TODO: Use cloud function instead.
    await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .updateData({
        'quota.today': today,
        'stats.proposed': proposed,
      });

    if (AddQuoteInputs.quote.id.isEmpty) {
      await addNewTempQuote(
        comments: comments,
        references: references,
        topics: topics,
      );

    } else {
      await saveExistingTempQuote(
        comments  : comments,
        references: references,
        topics    : topics,
      );
    }

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

List<Map<String, dynamic>> formatReferences() {
  final references = List<Map<String, dynamic>>();

  if (AddQuoteInputs.reference.name.isEmpty) {
    return references;
  }

  references.add(
    {
      'lang'          : AddQuoteInputs.reference.lang,
      'links'         : [],
      'name'          : AddQuoteInputs.reference.name,
      'summary'       : AddQuoteInputs.reference.summary,
      'type'          : {
        'primary'     : AddQuoteInputs.reference.type.primary,
        'secondary'   : AddQuoteInputs.reference.type.secondary,
      },
      'urls'          : {
        'affiliate'   : AddQuoteInputs.reference.urls.affiliate,
        'amazon'      : AddQuoteInputs.reference.urls.amazon,
        'facebook'    : AddQuoteInputs.reference.urls.facebook,
        'image'       : AddQuoteInputs.reference.urls.image,
        'netflix'     : AddQuoteInputs.reference.urls.netflix,
        'primeVideo'  : AddQuoteInputs.reference.urls.primeVideo,
        'twitch'      : AddQuoteInputs.reference.urls.twitch,
        'twitter'     : AddQuoteInputs.reference.urls.twitter,
        'website'     : AddQuoteInputs.reference.urls.website,
        'wikipedia'   : AddQuoteInputs.reference.urls.wikipedia,
        'youTube'     : AddQuoteInputs.reference.urls.youTube,
      },
    }
  );

  return references;
}


Future saveExistingTempQuote({
  List<String> comments,
  List<Map<String, dynamic>> references,
  Map<String, bool> topics,
}) async {

  final userAuth = await userState.userAuth;

  await Firestore.instance
    .collection('tempquotes')
    .document(AddQuoteInputs.quote.id)
    .setData({
      'author': {
        'id'          : AddQuoteInputs.author.id,
        'job'         : AddQuoteInputs.author.job,
        'jobLang'     : {},
        'name'        : AddQuoteInputs.author.name,
        'summary'     : AddQuoteInputs.author.summary,
        'summaryLang' : {},
        'updatedAt'   : DateTime.now(),
        'urls': {
          'affiliate' : AddQuoteInputs.author.urls.affiliate,
          'amazon'    : AddQuoteInputs.author.urls.amazon,
          'facebook'  : AddQuoteInputs.author.urls.facebook,
          'image'     : AddQuoteInputs.author.urls.image,
          'netflix'   : AddQuoteInputs.author.urls.netflix,
          'primeVideo': AddQuoteInputs.author.urls.primeVideo,
          'twitch'    : AddQuoteInputs.author.urls.twitch,
          'twitter'   : AddQuoteInputs.author.urls.twitter,
          'website'   : AddQuoteInputs.author.urls.website,
          'wikipedia' : AddQuoteInputs.author.urls.wikipedia,
          'youTube'   : AddQuoteInputs.author.urls.youTube,
        }
      },
      'comments'      : comments,
      'createdAt'     : DateTime.now(),
      'lang'          : AddQuoteInputs.quote.lang,
      'name'          : AddQuoteInputs.quote.name,
      'mainReference' : {
        'id'  : AddQuoteInputs.reference.id,
        'name': AddQuoteInputs.reference.name,
      },
      'references'    : references,
      'region'        : AddQuoteInputs.region,
      'topics'        : topics,
      'user': {
        'id': userAuth.uid,
      },
      'updatedAt'     : DateTime.now(),
      'validation'    : {
        'comment': {
          'name'      : '',
          'updatedAt' : DateTime.now(),
        },
        'status'      : 'proposed',
        'updatedAt'   : DateTime.now(),
      }
    });
}
