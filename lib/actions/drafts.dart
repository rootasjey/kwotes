import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fig_style/components/data_quote_inputs.dart';
import 'package:fig_style/screens/signin.dart';
import 'package:fig_style/state/user.dart';
import 'package:fig_style/types/temp_quote.dart';
import 'package:fig_style/utils/app_storage.dart';
import 'package:fig_style/utils/snack.dart';

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
      Snack.e(
        context: context,
        message: "The quote's content cannot be empty.",
      );

      return false;
    }

    final comments = <String>[];

    if (DataQuoteInputs.comment.isNotEmpty) {
      comments.add(DataQuoteInputs.comment);
    }

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
        'author': DataQuoteInputs.author.toJSON(withId: true),
        'comments': comments,
        'createdAt': DateTime.now(),
        'lang': DataQuoteInputs.quote.lang,
        'name': DataQuoteInputs.quote.name,
        'reference': DataQuoteInputs.reference.toJSON(withId: true),
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

    final topics = Map<String, bool>();

    DataQuoteInputs.quote.topics.forEach((topic) {
      topics[topic] = true;
    });

    try {
      final userAuth = stateUser.userAuth;

      Map<String, dynamic> draft = {
        'author': DataQuoteInputs.author.toJSON(withId: true),
        'comments': comments,
        'createdAt': DateTime.now(),
        'lang': DataQuoteInputs.quote.lang,
        'name': DataQuoteInputs.quote.name,
        'reference': DataQuoteInputs.reference.toJSON(withId: true),
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
