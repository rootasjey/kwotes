import "package:cloud_firestore/cloud_firestore.dart";
import "package:cloud_functions/cloud_functions.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/cloud_fun_error.dart";
import "package:kwotes/types/firestore/document_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/quote_list.dart";
import "package:kwotes/types/user_action_response.dart";
import "package:loggy/loggy.dart";
import "package:kwotes/types/create_account_response.dart";

/// Network interface for user's actions.
class UserActions {
  /// Add a quote to a user's list.
  static Future<bool> addQuoteToList({
    required Quote quote,
    required String userId,
    required String listId,
  }) async {
    if (userId.isEmpty) {
      return false;
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("lists")
          .doc(listId)
          .collection("quotes")
          .add(quote.toMapFavourite());
      return true;
    } catch (error) {
      GlobalLoggy().loggy.error(error);
      return false;
    }
  }

  /// Check email availability accross the app.
  static Future<bool> checkEmailAvailability(String email) async {
    try {
      final HttpsCallableResult resp = await Utils.lambda
          .fun("users-checkEmailAvailability")
          .call({"email": email});

      final bool? isAvailable = resp.data["isAvailable"];
      return isAvailable ?? false;
    } on FirebaseFunctionsException catch (exception) {
      GlobalLoggy()
          .loggy
          .error("[code: ${exception.code}] - ${exception.message}");
      return false;
    } catch (error) {
      GlobalLoggy().loggy.error(error);
      return false;
    }
  }

  /// Check email format.
  static bool checkEmailFormat(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}")
        .hasMatch(email);
  }

  /// Check username availability.
  static Future<bool> checkUsernameAvailability(String username) async {
    try {
      final HttpsCallableResult resp = await Utils.lambda
          .fun("users-checkUsernameAvailability")
          .call({"name": username});
      return resp.data["isAvailable"] ?? false;
    } on FirebaseFunctionsException catch (exception) {
      GlobalLoggy()
          .loggy
          .error("[code: ${exception.code}] - ${exception.message}");
      return false;
    } catch (error) {
      GlobalLoggy().loggy.error(error);
      return false;
    }
  }

  /// Check username format.
  /// Must contains 3 or more alpha-numerical characters.
  static bool checkUsernameFormat(String username) {
    final String? str = RegExp("[a-zA-Z0-9_]{3,}").stringMatch(username);
    return username == str;
  }

  /// Create a new account.
  static Future<CreateAccountResponse> createAccount({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await Utils.lambda.fun("users-createAccount").call({
        "username": username,
        "password": password,
        "email": email,
      });

      return CreateAccountResponse.fromMap(response.data);
    } on FirebaseFunctionsException catch (exception) {
      GlobalLoggy()
          .loggy
          .error("[code: ${exception.code}] - ${exception.message}");

      return CreateAccountResponse(
        success: false,
        error: CloudFunError(
          code: exception.code,
          message: exception.message ?? "",
        ),
      );
    } catch (error) {
      return CreateAccountResponse(
        success: false,
        error: CloudFunError(
          code: "",
          message: error.toString(),
        ),
      );
    }
  }

  /// Create a new list.
  static Future<QuoteList?> createList({
    required String name,
    required String description,
    required String userId,
  }) async {
    try {
      final DocumentMap documentRef = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("lists")
          .add({
        "name": name,
        "description": description,
        "is_public": false,
      });

      final snapshot = await documentRef.get();
      final map = snapshot.data();

      if (!snapshot.exists || map == null) {
        return null;
      }

      map["id"] = snapshot.id;
      return QuoteList.fromMap(map);
    } catch (error) {
      GlobalLoggy().loggy.error(error);
      return null;
    }
  }

  /// Fetch user's lists until [limit].
  static Future<List<QuoteList>> fetchLists({
    required String userId,
    limit = 10,
  }) async {
    final List<QuoteList> quoteLists = [];

    if (userId.isEmpty) {
      return quoteLists;
    }

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("lists")
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        return quoteLists;
      }

      for (var doc in snapshot.docs) {
        final map = doc.data();
        map["id"] = doc.id;
        quoteLists.add(QuoteList.fromMap(map));
      }

      return quoteLists;
    } catch (error) {
      return quoteLists;
    }
  }

  /// Update user's email.
  static Future<UserActionResponse> updateEmail({
    required String email,
    required String idToken,
  }) async {
    try {
      final HttpsCallableResult response =
          await Utils.lambda.fun("users-updateEmail").call({
        "email": email,
        "id_token": idToken,
      });

      return UserActionResponse.fromMap(response.data);
    } catch (error) {
      return UserActionResponse(
        success: false,
      );
    }
  }
}
