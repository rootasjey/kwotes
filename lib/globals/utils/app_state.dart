import "dart:async";
import "dart:ui";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:cloud_functions/cloud_functions.dart";
import "package:firebase_auth/firebase_auth.dart" as firebase_auth;
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/action_return_value.dart";
import "package:kwotes/types/alias/json_alias.dart";
import "package:kwotes/types/cloud_fun_error.dart";
import "package:kwotes/types/cloud_fun_response.dart";
import "package:kwotes/types/create_account_response.dart";
import "package:kwotes/types/credentials.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";
import "package:kwotes/types/firestore/doc_snapshot_stream_subscription.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/user/user_auth.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:kwotes/types/user_action_response.dart";
import "package:loggy/loggy.dart";
import "package:purchases_flutter/purchases_flutter.dart";

class AppState with UiLoggy {
  AppState() {
    // userAuth.update((value) {
    //   return firebase_auth.FirebaseAuth.instance.currentUser;
    // });

    // if (firebase_auth.FirebaseAuth.instance.currentUser != null) {
    //   signIn();
    // }
  }

  /// Firebase auth signal instance.
  final Signal<UserAuth?> userAuth = createSignal(null);

  /// Firestore signal instance.
  final Signal<UserFirestore> userFirestore = createSignal(
    UserFirestore.empty(),
  );

  /// Whether the app should show the navigation bar
  /// (e.g. when displaying quote page).
  final Signal<bool> showNavigationBar = createSignal(true);

  /// App frame color signal.
  final Signal<Color> frameBorderColor = createSignal(
    const Color.fromRGBO(241, 237, 255, 1.0),
  );

  /// Firebase auth stream subscription.
  StreamSubscription<firebase_auth.User?>? userAuthSubscription;

  /// Firestore stream subscription.
  DocSnapshotStreamSubscription? userFirestoreSubscription;

  /// Whether the user is authenticated.
  bool get userAuthenticated => userAuth.value != null;

  /// Refresh the premium status of the user.
  Future<void> refreshPremiumPlan() async {
    if (userAuth.value == null) return;

    final String userId = userAuth.value?.uid ?? "";
    if (userId.isEmpty) return;

    final bool hasPremiumPlan = await Utils.monetization.hasPremiumPlan();
    userFirestore.update(
      (UserFirestore previousValue) => previousValue.copyWith(
        plan: hasPremiumPlan ? EnumUserPlan.premium : EnumUserPlan.free,
      ),
    );
  }

  /// Try to sign in the user.
  Future<UserAuth?> signIn({String? email, String? password}) async {
    try {
      final Credentials credentials = await Utils.vault.getCredentials();
      email = email ?? credentials.email;
      password = password ?? credentials.password;

      if (email.isEmpty || password.isEmpty) {
        signOut();
        return null;
      }

      final firebaseAuthInstance = firebase_auth.FirebaseAuth.instance;
      final authResult = await firebaseAuthInstance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      userAuth.update((value) => authResult.user);
      _listenToAuthChanges();
      _listenToFirestoreChanges();

      Utils.vault.setCredentials(
        email: email,
        password: password,
      );

      final String userId = authResult.user?.uid ?? "";
      if (userId.isNotEmpty) {
        await Utils.monetization.initOrLogin(userId);
        final bool hasPremium = await Utils.monetization.hasPremiumPlan();
        userFirestore.update(
          (UserFirestore previousValue) => previousValue.copyWith(
            plan: hasPremium ? EnumUserPlan.premium : EnumUserPlan.free,
          ),
        );

        Purchases.removeCustomerInfoUpdateListener(onCustomerInfoUpdated);
        Purchases.addCustomerInfoUpdateListener(onCustomerInfoUpdated);
      }

      return authResult.user;
    } catch (error) {
      Utils.vault.clearCredentials();
      return null;
    }
  }

  /// Sign out the user.
  Future<bool> signOut() async {
    try {
      await Utils.vault.clearCredentials();
      await firebase_auth.FirebaseAuth.instance.signOut();
      userAuth.update((value) => null);
      userFirestore.update((value) => UserFirestore.empty());
      return true;
    } catch (error) {
      loggy.error(error);
      return false;
    }
  }

  /// Sign up the user.
  /// Create a firebase auth user then a firestore user.
  Future<CreateAccountResponse> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    final CreateAccountResponse createAccountResponse =
        await UserActions.createAccount(
      email: email,
      username: username,
      password: password,
    );

    if (!createAccountResponse.success) {
      return createAccountResponse;
    }

    final UserAuth? userAuth = await signIn(email: email, password: password);
    createAccountResponse.success = userAuth != null;
    return createAccountResponse;
  }

  /// Delete the user account.
  /// Calls the `users-deleteAccount` lambda function.
  Future<ActionReturnValue> deleteAccount({
    required String password,
  }) async {
    if (userAuth.value == null) {
      return ActionReturnValue(
        success: false,
        reason: "User authentication is null. "
            "Maybe you're not authenticated.",
      );
    }

    try {
      final firebase_auth.AuthCredential authCred =
          firebase_auth.EmailAuthProvider.credential(
        email: userAuth.value?.email ?? "",
        password: password,
      );

      final firebase_auth.UserCredential? cred =
          await userAuth.value?.reauthenticateWithCredential(
        authCred,
      );

      final String? idToken = await cred?.user?.getIdToken();

      final response = await Utils.lambda.fun("users-deleteAccount").call({
        "idToken": idToken,
      });

      final ActionReturnValue returnValue =
          ActionReturnValue.fromMap(response.data);

      if (!returnValue.success) {
        return returnValue;
      }

      signOut();
      return ActionReturnValue(success: true);
    } on FirebaseFunctionsException catch (exception) {
      loggy.error("[code: ${exception.code}] - ${exception.message}");

      return ActionReturnValue(
        success: false,
        reason: exception.message ?? "",
        error: exception,
      );
    } catch (error) {
      loggy.error(error);

      return ActionReturnValue(
        success: false,
        reason: error.toString(),
        error: error,
      );
    }
  }

  /// Update the email of the user.
  Future<ActionReturnValue> updateEmail({
    required String password,
    required String newEmail,
  }) async {
    try {
      if (userAuth.value == null) {
        return ActionReturnValue(
          success: false,
          reason: "User authentication is null. "
              "Maybe you're not authenticated.",
        );
      }

      final credentials = firebase_auth.EmailAuthProvider.credential(
        email: userAuth.value?.email ?? "",
        password: password,
      );

      await userAuth.value?.reauthenticateWithCredential(credentials);
      final String? idToken = await userAuth.value?.getIdToken();

      final UserActionResponse response = await UserActions.updateEmail(
        email: newEmail,
        idToken: idToken ?? "",
      );

      if (!response.success) {
        return ActionReturnValue(
          success: false,
          error: response.error,
        );
      }

      signIn(
        email: newEmail,
        password: password,
      );

      return ActionReturnValue(success: true);
    } catch (error) {
      return ActionReturnValue(
        success: false,
        error: error,
      );
    }
  }

  /// Update password of the current user.
  Future<ActionReturnValue> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (userAuth.value == null) {
        return ActionReturnValue(
          success: false,
          reason:
              "User authentication is null. Maybe you're not authenticated.",
        );
      }

      final firebase_auth.AuthCredential credentials =
          firebase_auth.EmailAuthProvider.credential(
        email: userAuth.value?.email ?? "",
        password: currentPassword,
      );

      final firebase_auth.UserCredential? authResult =
          await userAuth.value?.reauthenticateWithCredential(credentials);

      if (authResult?.user == null) {
        return ActionReturnValue(
          success: false,
          reason:
              "You entered a wrong password or the user doesn't exist anymore.",
        );
      }

      await authResult?.user?.updatePassword(newPassword);
      Utils.vault.setPassword(newPassword);

      return ActionReturnValue(success: true, reason: "");
    } catch (error) {
      loggy.error(error);
      return ActionReturnValue(
        success: false,
        reason: error.toString(),
        error: error,
      );
    }
  }

  /// Update the username of the user.
  Future<CloudFunResponse> updateUsername(String newUsername) async {
    try {
      final response = await Utils.lambda.fun("users-updateUsername").call({
        "newUsername": newUsername,
      });

      return CloudFunResponse.fromMap(response.data);
    } catch (error) {
      return CloudFunResponse(
        success: false,
        error: CloudFunError(
          code: "",
          message: error.toString(),
        ),
      );
    }
  }

  /// Listen to firebase auth changes.
  void _listenToAuthChanges() {
    final firebaseAuthInstance = firebase_auth.FirebaseAuth.instance;

    userAuthSubscription?.cancel();
    userAuthSubscription = firebaseAuthInstance.userChanges().listen(
      (newUserAuth) {
        userAuth.update((value) => newUserAuth);
      },
      onError: (error) {
        loggy.error(error);
      },
      onDone: () {
        userAuthSubscription?.cancel();
        loggy.error("Connection to firebase auth closed.");
        userAuth.update((value) => null);
      },
    );
  }

  /// Listen to firestore document changes.
  void _listenToFirestoreChanges() async {
    // If the value is null, the user is not signed in.
    if (userAuth.value == null) {
      return;
    }

    userFirestoreSubscription?.cancel();
    userFirestoreSubscription = FirebaseFirestore.instance
        .collection("users")
        .doc(userAuth.value?.uid)
        .snapshots()
        .listen(
      (DocumentSnapshotMap snapshot) {
        final Json? map = snapshot.data();
        if (map == null) {
          return;
        }

        map["id"] = snapshot.id;
        userFirestore.update(
          (UserFirestore previousValue) => UserFirestore.fromMap(map).copyWith(
            plan: previousValue.plan,
          ),
        );
      },
      onError: (error) {
        loggy.error(error);
      },
      onDone: () {
        userFirestoreSubscription?.cancel();
        loggy.error("Connection to firestore closed.");
        userFirestore.update((value) => UserFirestore.empty());
      },
    );
  }

  void onCustomerInfoUpdated(CustomerInfo customerInfo) {
    final EnumUserPlan updatedPlan = getUpdatedPlan(customerInfo);

    userFirestore.update(
      (UserFirestore previousValue) => previousValue.copyWith(
        plan: updatedPlan,
      ),
    );
  }

  EnumUserPlan getUpdatedPlan(CustomerInfo customerInfo) {
    final Map<String, EntitlementInfo> activeEntitlements =
        customerInfo.entitlements.active;

    if (activeEntitlements.isEmpty) return EnumUserPlan.free;
    final bool hasPremium = activeEntitlements.containsKey("premium");

    if (!hasPremium) return EnumUserPlan.free;
    final EntitlementInfo? premiumEntitlement = activeEntitlements["premium"];
    if (premiumEntitlement == null) return EnumUserPlan.free;

    return premiumEntitlement.isActive
        ? EnumUserPlan.premium
        : EnumUserPlan.free;
  }
}
