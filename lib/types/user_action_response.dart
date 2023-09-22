import "dart:convert";

import "package:firebase_auth/firebase_auth.dart" as firebase_auth;

import "package:kwotes/types/cloud_fun_error.dart";
import "package:kwotes/types/user/user_firestore.dart";

/// User action performed in the cloud.
class UserActionResponse {
  UserActionResponse({
    this.success = true,
    this.message = "",
    this.error,
    this.user,
  });

  /// Whether the request was successful.
  bool success;

  /// Detailed about the performed action.
  final String message;

  /// Cloud function error.
  final CloudFunError? error;

  /// User who performed the action.
  final UserFirestore? user;

  /// Empty factory. Return a new empty instance.
  factory UserActionResponse.empty() {
    return UserActionResponse(
      success: false,
      user: UserFirestore.empty(),
      error: CloudFunError.empty(),
    );
  }

  /// Create a new instance from a specified source with the same structure.
  UserActionResponse copyWith({
    bool? success,
    String? message,
    CloudFunError? error,
    UserFirestore? user,
    firebase_auth.User? userAuth,
  }) {
    return UserActionResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  /// Convert to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "success": success,
      "message": message,
      "error": error?.toMap(),
      "user": user?.toMap(),
    };
  }

  /// Factory. Create a new instance from a map.
  factory UserActionResponse.fromMap(Map<String, dynamic> map) {
    return UserActionResponse(
      success: map["success"] ?? false,
      message: map["message"] ?? "",
      error: map["error"] != null ? CloudFunError.fromMap(map["error"]) : null,
      user: UserFirestore.fromMap(map["user"]),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActionResponse.fromJson(String source) =>
      UserActionResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "CreateAccountResp(success: $success, message: $message, error: $error, user: $user)";
  }

  @override
  bool operator ==(covariant UserActionResponse other) {
    if (identical(this, other)) return true;

    return other.success == success &&
        other.message == message &&
        other.error == error &&
        other.user == user;
  }

  @override
  int get hashCode {
    return success.hashCode ^ message.hashCode ^ error.hashCode ^ user.hashCode;
  }
}
