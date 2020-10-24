import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/components/data_quote_inputs.dart';
import 'package:memorare/screens/signin.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => Signin()),
    );
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
  if (DataQuoteInputs.quote.name.isEmpty) {
    showSnack(
      context: context,
      message: "The quote's content cannot be empty.",
      type: SnackType.error,
    );

    return false;
  }

  final comments = List<String>();

  if (DataQuoteInputs.comment.isNotEmpty) {
    comments.add(DataQuoteInputs.comment);
  }

  final references = formatReferences();

  final topics = Map<String, bool>();

  DataQuoteInputs.quote.topics.forEach((topic) {
    topics[topic] = true;
  });

  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      return false;
    }

    await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .collection('drafts')
        .add({
      'author': {
        'id': DataQuoteInputs.author.id,
        'job': DataQuoteInputs.author.job,
        'jobLang': {},
        'name': DataQuoteInputs.author.name,
        'summary': DataQuoteInputs.author.summary,
        'summaryLang': {},
        'updatedAt': DateTime.now(),
        'urls': {
          'affiliate': DataQuoteInputs.author.urls.affiliate,
          'amazon': DataQuoteInputs.author.urls.amazon,
          'facebook': DataQuoteInputs.author.urls.facebook,
          'image': DataQuoteInputs.author.urls.image,
          'netflix': DataQuoteInputs.author.urls.netflix,
          'primeVideo': DataQuoteInputs.author.urls.primeVideo,
          'twitch': DataQuoteInputs.author.urls.twitch,
          'twitter': DataQuoteInputs.author.urls.twitter,
          'website': DataQuoteInputs.author.urls.website,
          'wikipedia': DataQuoteInputs.author.urls.wikipedia,
          'youtube': DataQuoteInputs.author.urls.youtube,
        }
      },
      'comments': comments,
      'createdAt': DateTime.now(),
      'lang': DataQuoteInputs.quote.lang,
      'name': DataQuoteInputs.quote.name,
      'mainReference': {
        'id': DataQuoteInputs.reference.id,
        'name': DataQuoteInputs.reference.name,
      },
      'references': references,
      'region': DataQuoteInputs.region,
      'topics': topics,
      'user': {
        'id': userAuth.uid,
      },
      'updatedAt': DateTime.now(),
      'validation': {
        'comment': {
          'name': '',
          'updatedAt': DateTime.now(),
        },
        'status': 'proposed',
        'updatedAt': DateTime.now(),
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

  if (DataQuoteInputs.comment.isNotEmpty) {
    comments.add(DataQuoteInputs.comment);
  }

  final references = formatReferences();

  final topics = Map<String, bool>();

  DataQuoteInputs.quote.topics.forEach((topic) {
    topics[topic] = true;
  });

  try {
    final userAuth = await userState.userAuth;

    Map<String, dynamic> draft = {
      'author': {
        'id': DataQuoteInputs.author.id,
        'job': DataQuoteInputs.author.job,
        'jobLang': {},
        'name': DataQuoteInputs.author.name,
        'summary': DataQuoteInputs.author.summary,
        'summaryLang': {},
        'updatedAt': DateTime.now().toString(),
        'urls': {
          'affiliate': DataQuoteInputs.author.urls.affiliate,
          'amazon': DataQuoteInputs.author.urls.amazon,
          'facebook': DataQuoteInputs.author.urls.facebook,
          'image': DataQuoteInputs.author.urls.image,
          'netflix': DataQuoteInputs.author.urls.netflix,
          'primeVideo': DataQuoteInputs.author.urls.primeVideo,
          'twitch': DataQuoteInputs.author.urls.twitch,
          'twitter': DataQuoteInputs.author.urls.twitter,
          'website': DataQuoteInputs.author.urls.website,
          'wikipedia': DataQuoteInputs.author.urls.wikipedia,
          'youtube': DataQuoteInputs.author.urls.youtube,
        }
      },
      'comments': comments,
      'createdAt': DateTime.now().toString(),
      'isOffline': true,
      'lang': DataQuoteInputs.quote.lang,
      'name': DataQuoteInputs.quote.name,
      'mainReference': {
        'id': DataQuoteInputs.reference.id,
        'name': DataQuoteInputs.reference.name,
      },
      'references': references,
      'region': DataQuoteInputs.region,
      'topics': topics,
      'user': {
        'id': userAuth.uid,
      },
      'updatedAt': DateTime.now().toString(),
      'validation': {
        'comment': {
          'name': '',
          'updatedAt': DateTime.now().toString(),
        },
        'status': 'proposed',
        'updatedAt': DateTime.now().toString(),
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

  if (savedStringDrafts == null) {
    return drafts;
  }

  savedStringDrafts.forEach((savedStringDraft) {
    final data = jsonDecode(savedStringDraft);
    final draft = TempQuote.fromJSON(data);
    drafts.add(draft);
  });

  return drafts;
}
