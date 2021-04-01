import 'package:fig_style/state/user.dart';
import 'package:fig_style/types/author.dart';
import 'package:fig_style/utils/app_logger.dart';
import 'package:fig_style/utils/cloud.dart';

class AuthorsActions {
  static Future<bool> delete({
    Author author,
    bool deleteAuthor = false,
    bool deleteReference = false,
  }) async {
    try {
      final userAuth = stateUser.userAuth;
      final idToken = await userAuth.getIdToken();

      final response = await Cloud.fun('authors-deleteAuthors').call({
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
