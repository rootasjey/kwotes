import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';

void clearOfflineDrafts() {
  appLocalStorage.clearDrafts();
}

Future<bool> deleteDraft({
  BuildContext context,
  TempQuote draft,
}) async {

  final userAuth = await userState.userAuth;

  if (userAuth == null) {
    FluroRouter.router.navigateTo(context, SigninRoute);
    return false;
  }

  final id = draft.id;

  try {
    await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('drafts')
      .document(id)
      .delete();

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}


bool deleteOfflineDraft({String createdAt}) {
  final drafts = appLocalStorage.getDrafts();

  drafts.removeWhere((draftStr) {
    final draft = jsonDecode(draftStr) as Map<String, dynamic>;
    return draft['createdAt'] == createdAt;
  });

  appLocalStorage.setDrafts(drafts);

  return true;
}

Future<bool> saveDraft({
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

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;
    }

    await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .collection('drafts')
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
          'youtube'   : AddQuoteInputs.author.urls.youtube,
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

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

Future<bool> saveOfflineDraft({
  BuildContext context,
}) async {

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

    Map<String, dynamic> draft = {
      'author'        : {
        'id'          : AddQuoteInputs.author.id,
        'job'         : AddQuoteInputs.author.job,
        'jobLang'     : {},
        'name'        : AddQuoteInputs.author.name,
        'summary'     : AddQuoteInputs.author.summary,
        'summaryLang' : {},
        'updatedAt'   : DateTime.now().toString(),
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
          'youtube'   : AddQuoteInputs.author.urls.youtube,
        }
      },
      'comments'      : comments,
      'createdAt'     : DateTime.now().toString(),
      'isOffline'     : true,
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
      'updatedAt'     : DateTime.now().toString(),
      'validation'    : {
        'comment'     : {
          'name'      : '',
          'updatedAt' : DateTime.now().toString(),
        },
        'status'      : 'proposed',
        'updatedAt'   : DateTime.now().toString(),
      }
    };

    final draftString = jsonEncode(draft);
    appLocalStorage.saveDraft(draftString: draftString);

    return true;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

List<TempQuote> getOfflineDrafts() {
  final drafts = List<TempQuote>();
  final savedStringDrafts = appLocalStorage.getDrafts();

  if (savedStringDrafts == null) { return drafts; }

  savedStringDrafts.forEach((savedStringDraft) {
    final data = jsonDecode(savedStringDraft);
    final draft = TempQuote.fromJSON(data);
    drafts.add(draft);
  });

  return drafts;
}
