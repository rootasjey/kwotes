import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/temp_quote.dart';
import 'package:figstyle/utils/snack.dart';

class TempQuotesActions {
  static Future addNewTempQuote({
    List<String> comments,
    Map<String, bool> topics,
  }) async {
    final userAuth = stateUser.userAuth;

    await FirebaseFirestore.instance.collection('tempquotes').add({
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
  }

  static Future<bool> deleteTempQuote({
    BuildContext context,
    TempQuote tempQuote,
  }) async {
    try {
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

  static Future<bool> deleteTempQuoteAdmin({
    BuildContext context,
    TempQuote tempQuote,
  }) async {
    try {
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

  static String getResultMessage({
    AddQuoteType actionIntent,
    AddQuoteType actionResult,
  }) {
    if ((actionIntent == actionResult) &&
        actionIntent == AddQuoteType.tempquote) {
      return DataQuoteInputs.quote.id.isEmpty
          ? 'Your quote has been successfully proposed'
          : 'Your quote has been successfully saved';
    }

    if ((actionIntent == actionResult) && actionIntent == AddQuoteType.draft) {
      return 'Your draft has been successfully saved';
    }

    if (actionIntent == AddQuoteType.tempquote &&
        actionResult == AddQuoteType.draft) {
      return "We saved your draft";
    }

    if (actionIntent == AddQuoteType.tempquote &&
        actionResult == AddQuoteType.offline) {
      return "We saved your offline draft";
    }

    if (actionIntent == AddQuoteType.draft &&
        actionResult == AddQuoteType.offline) {
      return "We saved your offline draft";
    }

    return 'Your quote has been successfully saved';
  }

  static String getResultSubMessage({
    AddQuoteType actionIntent,
    AddQuoteType actionResult,
  }) {
    if ((actionIntent == actionResult) &&
        actionIntent == AddQuoteType.tempquote) {
      return DataQuoteInputs.quote.id.isEmpty
          ? 'Soon, a moderator will review it and it will be validated if everything is alright'
          : "It's time to let things happen";
    }

    if ((actionIntent == actionResult) && actionIntent == AddQuoteType.draft) {
      return 'You can edit it later and propose it when you are ready';
    }

    if (actionIntent == AddQuoteType.tempquote &&
        actionResult == AddQuoteType.draft) {
      return "We couldn't propose your quote at the moment (maybe you've reached your quota) but we saved it in your drafts";
    }

    if (actionIntent == AddQuoteType.tempquote &&
        actionResult == AddQuoteType.offline) {
      return "It seems that you've no internet connection anymore, but we saved it in your offline drafts";
    }

    if (actionIntent == AddQuoteType.draft &&
        actionResult == AddQuoteType.offline) {
      return "It seems that you've no internet connection anymore, but we saved it in your offline drafts";
    }

    return "It's time to let things happen";
  }

  static Future<bool> proposeQuote({
    BuildContext context,
  }) async {
    if (DataQuoteInputs.quote.name.isEmpty) {
      Snack.e(
        context: context,
        message: "The quote's content cannot be empty.",
      );

      return false;
    }

    if (DataQuoteInputs.quote.topics.length == 0) {
      Snack.e(
        context: context,
        message: "You must select at least 1 topics for the quote.",
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
      if (DataQuoteInputs.quote.id.isEmpty) {
        await addNewTempQuote(
          comments: comments,
          topics: topics,
        );
      } else {
        await saveExistingTempQuote(
          comments: comments,
          topics: topics,
        );
      }

      return true;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  static List<Map<String, dynamic>> formatReferences() {
    final references = <Map<String, dynamic>>[];

    if (DataQuoteInputs.reference.name.isEmpty) {
      return references;
    }

    references.add({
      'id': DataQuoteInputs.reference.id,
      'lang': DataQuoteInputs.reference.lang,
      'links': [],
      'name': DataQuoteInputs.reference.name,
      'release': {
        'original': DataQuoteInputs.reference.release.original,
        'beforeJC': DataQuoteInputs.reference.release.beforeJC,
      },
      'summary': DataQuoteInputs.reference.summary,
      'type': {
        'primary': DataQuoteInputs.reference.type.primary,
        'secondary': DataQuoteInputs.reference.type.secondary,
      },
      'urls': {
        'amazon': DataQuoteInputs.reference.urls.amazon,
        'facebook': DataQuoteInputs.reference.urls.facebook,
        'image': DataQuoteInputs.reference.urls.image,
        'instagram': DataQuoteInputs.reference.urls.instagram,
        'netflix': DataQuoteInputs.reference.urls.netflix,
        'primeVideo': DataQuoteInputs.reference.urls.primeVideo,
        'twitch': DataQuoteInputs.reference.urls.twitch,
        'twitter': DataQuoteInputs.reference.urls.twitter,
        'website': DataQuoteInputs.reference.urls.website,
        'wikipedia': DataQuoteInputs.reference.urls.wikipedia,
        'youtube': DataQuoteInputs.reference.urls.youtube,
      },
    });

    return references;
  }

  static Future saveExistingTempQuote({
    List<String> comments,
    Map<String, bool> topics,
  }) async {
    await FirebaseFirestore.instance
        .collection('tempquotes')
        .doc(DataQuoteInputs.quote.id)
        .update({
      'author': DataQuoteInputs.author.toJSON(withId: true),
      'comments': comments,
      'lang': DataQuoteInputs.quote.lang,
      'name': DataQuoteInputs.quote.name,
      'reference': DataQuoteInputs.reference.toJSON(withId: true),
      'topics': topics,
      'updatedAt': DateTime.now(),
    });
  }

  static Future<bool> validateTempQuote({
    TempQuote tempQuote,
    String uid,
  }) async {
    try {
      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'tempQuotes-validate',
      );

      final idToken = await stateUser.userAuth.getIdToken();

      final resp = await callable.call({
        'tempQuoteId': tempQuote.id,
        'idToken': idToken,
      });

      final isOk = resp.data['success'] as bool;
      return isOk;
    } on CloudFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
      return false;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }
}
