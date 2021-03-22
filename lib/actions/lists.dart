import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/types/background_op.dart';
import 'package:figstyle/utils/app_logger.dart';
import 'package:figstyle/utils/background_op_manager.dart';
import 'package:figstyle/utils/cloud.dart';
import 'package:figstyle/utils/flash_helper.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/user_quotes_list.dart';

/// Network interface for user's quotes lists.
class ListsActions {
  /// Add quotes to a target list.
  static Future<bool> addQuote({
    @required String listId,
    @required List<String> quoteIds,
  }) async {
    try {
      final userAuth = stateUser.userAuth;
      final idToken = await userAuth.getIdToken();

      final response = await Cloud.fun('lists-addQuotes').call({
        'listId': listId,
        'idToken': idToken,
        'quoteIds': quoteIds,
      });

      final responseData = response.data;
      final bool success = responseData['success'] ?? false;
      return success;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// Create a new list for the auth user.
  static Future<UserQuotesList> create({
    @required String name,
    String description = '',
    String iconUrl = '',
    bool isPublic = false,
    List<String> quoteIds = const [],
  }) async {
    try {
      final userAuth = stateUser.userAuth;
      final idToken = await userAuth.getIdToken();

      final response = await Cloud.fun('lists-createList').call({
        'name': name,
        'description': description,
        'isPublic': isPublic,
        'idToken': idToken,
        'quoteIds': quoteIds,
      });

      final responseData = response.data;
      final bool success = responseData['success'] ?? false;

      if (success) {
        final listSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(userAuth.uid)
            .collection('lists')
            .doc(responseData['list']['id'])
            .get();

        final listData = listSnap.data();
        listData['id'] = listSnap.id;
        final userQuotesList = UserQuotesList.fromJSON(listData);
        return userQuotesList;
      }

      return null;
    } catch (error) {
      appLogger.e(error);
      return null;
    }
  }

  /// Delete an existig user's list.
  static Future<bool> delete({
    @required String id,
  }) async {
    try {
      BackgroundOpManager.addListOp(BackgroundOp(itemId: id));
      final userAuth = stateUser.userAuth;
      final idToken = await userAuth.getIdToken();

      final response = await Cloud.fun('lists-deleteList').call({
        'listId': id,
        'idToken': idToken,
      });

      final responseData = response.data;
      final bool success = responseData['success'] ?? false;

      FlashHelper.dismissProgress(id: id);

      if (!success) {
        throw new ErrorDescription("The delete operation wasn't successful.");
      }

      BackgroundOpManager.setOpDone(id);
      return success;
    } catch (error) {
      appLogger.e(error);
      BackgroundOpManager.setOpDone(id);
      Snack.e(
        context: BackgroundOpManager.context,
        message: 'There was and issue while deleting the list. Try again later',
      );

      return false;
    }
  }

  /// Remove quotes from a target list.
  static Future<bool> removeFrom({
    @required String id,
    @required Quote quote,
  }) async {
    try {
      final userAuth = stateUser.userAuth;
      final idToken = await userAuth.getIdToken();

      final response = await Cloud.fun('lists-removeQuotes').call({
        'listId': id,
        'idToken': idToken,
        'quoteIds': [quote.id],
      });

      final responseData = response.data;
      final bool success = responseData['success'] ?? false;
      return success;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// Update an existing user's quotes list.
  /// The updatable properties are name, description, isPublic.
  static Future<bool> update({
    @required String id,
    String iconUrl = '',
    @required String name,
    String description = '',
    bool isPublic = false,
  }) async {
    try {
      final userAuth = stateUser.userAuth;
      final idToken = await userAuth.getIdToken();

      final response = await Cloud.fun('lists-updateList').call({
        'idToken': idToken,
        'listId': id,
        'name': name,
        'description': description,
        'isPublic': isPublic,
      });

      final responseData = response.data;
      final bool success = responseData['success'] ?? false;
      return success;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }
}
