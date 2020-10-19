import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/data_quote_inputs.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:memorare/utils/snack.dart';

enum AddQuoteType {
  draft,
  offline,
  tempquote,
}

Future addNewTempQuote({
  List<String> comments,
  List<Map<String, dynamic>> references,
  Map<String, bool> topics,
}) async {
  final userAuth = await userState.userAuth;

  await Firestore.instance.collection('tempquotes').add({
    'author': {
      'id': AddQuoteInputs.author.id,
      'job': AddQuoteInputs.author.job,
      'jobLang': {},
      'name': AddQuoteInputs.author.name,
      'summary': AddQuoteInputs.author.summary,
      'summaryLang': {},
      'updatedAt': DateTime.now(),
      'urls': {
        'affiliate': AddQuoteInputs.author.urls.affiliate,
        'amazon': AddQuoteInputs.author.urls.amazon,
        'facebook': AddQuoteInputs.author.urls.facebook,
        'image': AddQuoteInputs.author.urls.image,
        'netflix': AddQuoteInputs.author.urls.netflix,
        'primeVideo': AddQuoteInputs.author.urls.primeVideo,
        'twitch': AddQuoteInputs.author.urls.twitch,
        'twitter': AddQuoteInputs.author.urls.twitter,
        'website': AddQuoteInputs.author.urls.website,
        'wikipedia': AddQuoteInputs.author.urls.wikipedia,
        'youtube': AddQuoteInputs.author.urls.youtube,
      }
    },
    'comments': comments,
    'createdAt': DateTime.now(),
    'lang': AddQuoteInputs.quote.lang,
    'name': AddQuoteInputs.quote.name,
    'mainReference': {
      'id': AddQuoteInputs.reference.id,
      'name': AddQuoteInputs.reference.name,
    },
    'references': references,
    'region': AddQuoteInputs.region,
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

Future<bool> deleteTempQuoteAdmin({
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

String getResultMessage(
    {AddQuoteType actionIntent, AddQuoteType actionResult}) {
  if ((actionIntent == actionResult) &&
      actionIntent == AddQuoteType.tempquote) {
    return AddQuoteInputs.quote.id.isEmpty
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

String getResultSubMessage(
    {AddQuoteType actionIntent, AddQuoteType actionResult}) {
  if ((actionIntent == actionResult) &&
      actionIntent == AddQuoteType.tempquote) {
    return AddQuoteInputs.quote.id.isEmpty
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
    if (AddQuoteInputs.quote.id.isEmpty) {
      await addNewTempQuote(
        comments: comments,
        references: references,
        topics: topics,
      );
    } else {
      await saveExistingTempQuote(
        comments: comments,
        references: references,
        topics: topics,
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

  references.add({
    'lang': AddQuoteInputs.reference.lang,
    'links': [],
    'name': AddQuoteInputs.reference.name,
    'summary': AddQuoteInputs.reference.summary,
    'type': {
      'primary': AddQuoteInputs.reference.type.primary,
      'secondary': AddQuoteInputs.reference.type.secondary,
    },
    'urls': {
      'affiliate': AddQuoteInputs.reference.urls.affiliate,
      'amazon': AddQuoteInputs.reference.urls.amazon,
      'facebook': AddQuoteInputs.reference.urls.facebook,
      'image': AddQuoteInputs.reference.urls.image,
      'netflix': AddQuoteInputs.reference.urls.netflix,
      'primeVideo': AddQuoteInputs.reference.urls.primeVideo,
      'twitch': AddQuoteInputs.reference.urls.twitch,
      'twitter': AddQuoteInputs.reference.urls.twitter,
      'website': AddQuoteInputs.reference.urls.website,
      'wikipedia': AddQuoteInputs.reference.urls.wikipedia,
      'youtube': AddQuoteInputs.reference.urls.youtube,
    },
  });

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
      'id': AddQuoteInputs.author.id,
      'job': AddQuoteInputs.author.job,
      'jobLang': {},
      'name': AddQuoteInputs.author.name,
      'summary': AddQuoteInputs.author.summary,
      'summaryLang': {},
      'updatedAt': DateTime.now(),
      'urls': {
        'affiliate': AddQuoteInputs.author.urls.affiliate,
        'amazon': AddQuoteInputs.author.urls.amazon,
        'facebook': AddQuoteInputs.author.urls.facebook,
        'image': AddQuoteInputs.author.urls.image,
        'netflix': AddQuoteInputs.author.urls.netflix,
        'primeVideo': AddQuoteInputs.author.urls.primeVideo,
        'twitch': AddQuoteInputs.author.urls.twitch,
        'twitter': AddQuoteInputs.author.urls.twitter,
        'website': AddQuoteInputs.author.urls.website,
        'wikipedia': AddQuoteInputs.author.urls.wikipedia,
        'youtube': AddQuoteInputs.author.urls.youtube,
      }
    },
    'comments': comments,
    'createdAt': DateTime.now(),
    'lang': AddQuoteInputs.quote.lang,
    'name': AddQuoteInputs.quote.name,
    'mainReference': {
      'id': AddQuoteInputs.reference.id,
      'name': AddQuoteInputs.reference.name,
    },
    'references': references,
    'region': AddQuoteInputs.region,
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
