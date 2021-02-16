import 'package:cloud_functions/cloud_functions.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:figstyle/types/quote.dart';

class QuotesActions {
  static Future<bool> delete({
    Quote quote,
    bool deleteAuthor = false,
    bool deleteReference = false,
  }) async {
    try {
      final userAuth = stateUser.userAuth;
      final idToken = await userAuth.getIdToken();

      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'quotes-deleteQuotes',
      );

      final response = await callable.call({
        'quoteIds': [quote.id],
        'idToken': idToken,
        'deleteAuthor': deleteAuthor,
        'deleteReference': deleteReference,
      });

      final responseData = response.data;
      final bool success = responseData['success'];
      return success;
    } catch (error) {
      appLogger.e("[QuotesActions] Delete quotes failed");
      appLogger.e(error);
      return false;
    }
  }
}
