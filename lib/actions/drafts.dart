import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/types/enums.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/temp_quotes.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/temp_quote.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/snack.dart';

/// Network interface for drafts.
class DraftsActions {
  static void clearOfflineData() {
    appStorage.clearDrafts();
  }

  /// Delete a single online drafts.
  static Future<bool> deleteItem({
    BuildContext context,
    TempQuote draft,
  }) async {
    final userAuth = stateUser.userAuth;

    if (userAuth == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => Signin()),
      );
      return false;
    }

    final id = draft.id;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .collection('drafts')
          .doc(id)
          .delete();

      return true;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// Delete an offline draft item.
  static bool deleteOfflineItem({String createdAt}) {
    final drafts = appStorage.getDrafts();

    drafts.removeWhere((draftStr) {
      final draft = jsonDecode(draftStr) as Map<String, dynamic>;
      return draft['createdAt'] == createdAt;
    });

    appStorage.setDrafts(drafts);

    return true;
  }

  /// Save an online draft item.
  static Future<bool> saveItem({
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

    final comments = <String>[];

    if (DataQuoteInputs.comment.isNotEmpty) {
      comments.add(DataQuoteInputs.comment);
    }

    final references = TempQuotesActions.formatReferences();

    final topics = Map<String, bool>();

    DataQuoteInputs.quote.topics.forEach((topic) {
      topics[topic] = true;
    });

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        return false;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
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

  /// Save an offline draft item.
  static Future<bool> saveOfflineItem({
    BuildContext context,
  }) async {
    final comments = <String>[];

    if (DataQuoteInputs.comment.isNotEmpty) {
      comments.add(DataQuoteInputs.comment);
    }

    final references = TempQuotesActions.formatReferences();

    final topics = Map<String, bool>();

    DataQuoteInputs.quote.topics.forEach((topic) {
      topics[topic] = true;
    });

    try {
      final userAuth = stateUser.userAuth;

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
      appStorage.saveDraft(draftString: draftString);

      return true;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// Return offline drafts items list.
  static List<TempQuote> getOfflineData() {
    final drafts = <TempQuote>[];
    final savedStringDrafts = appStorage.getDrafts();

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
}
