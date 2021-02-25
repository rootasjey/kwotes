import 'package:cloud_functions/cloud_functions.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthorsActions {
  static Future<bool> delete({
    Author author,
    bool deleteAuthor = false,
    bool deleteReference = false,
  }) async {
    try {
      final userAuth = stateUser.userAuth;
      final idToken = await userAuth.getIdToken();

      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable('authors-deleteAuthors');

      final response = await callable.call({
        'authorIds': [author.id],
        'idToken': idToken,
      });

      final responseData = response.data;
      final bool success = responseData['success'];
      return success;
    } catch (error) {
      appLogger.e("[AuthorsActions] Delete authors failed");
      appLogger.e(error);
      return false;
    }
  }
}
