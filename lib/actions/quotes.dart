import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/app_logger.dart';
import 'package:figstyle/utils/cloud.dart';
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

      final response = await Cloud.fun('quotes-deleteQuotes').call({
        'quoteIds': [quote.id],
        'idToken': idToken,
        'deleteAuthor': deleteAuthor,
        'deleteReference': deleteReference,
      });

      final responseData = response.data;
      return responseData['success'] as bool;
    } catch (error) {
      appLogger.e("[QuotesActions] Delete quotes failed");
      appLogger.e(error);
      return false;
    }
  }
}
