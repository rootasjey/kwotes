import 'package:fig_style/state/user.dart';
import 'package:fig_style/types/reference.dart';
import 'package:fig_style/utils/app_logger.dart';
import 'package:fig_style/utils/cloud.dart';

class ReferencesActions {
  static Future<bool> delete({
    Reference reference,
    bool deleteAuthor = false,
    bool deleteReference = false,
  }) async {
    try {
      final userAuth = stateUser.userAuth;
      final idToken = await userAuth.getIdToken();

      final response = await Cloud.fun('references-deleteReferences').call({
        'referenceIds': [reference.id],
        'idToken': idToken,
      });

      final responseData = response.data;
      final bool success = responseData['success'];
      return success;
    } catch (error) {
      appLogger.e("[ReferencesActions] Delete authors failed");
      appLogger.e(error);
      return false;
    }
  }
}
