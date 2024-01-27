import "dart:convert";

import "package:firebase_auth/firebase_auth.dart" as firebase_auth;

import "package:kwotes/types/cloud_fun_error.dart";
import "package:kwotes/types/user/user_firestore.dart";

class CreateAccountResponse {
  CreateAccountResponse({
    this.success = true,
    this.message = "",
    this.error,
    this.user,
  });

  bool success;
  final String message;
  final CloudFunError? error;
  final UserFirestore? user;

  factory CreateAccountResponse.empty() {
    return CreateAccountResponse(
      success: false,
      user: UserFirestore.empty(),
      error: CloudFunError.empty(),
    );
  }

  CreateAccountResponse copyWith({
    bool? success,
    String? message,
    CloudFunError? error,
    UserFirestore? user,
    firebase_auth.User? userAuth,
  }) {
    return CreateAccountResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "success": success,
      "message": message,
      "error": error?.toMap(),
      "user": user?.toMap(),
    };
  }

  factory CreateAccountResponse.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return CreateAccountResponse.empty();
    }

    return CreateAccountResponse(
      success: map["success"] ?? false,
      message: map["message"] ?? "",
      error: CloudFunError.fromMap(map["error"]),
      user: UserFirestore.fromMap(map["user"]),
    );
  }

  String toJson() => json.encode(toMap());

  factory CreateAccountResponse.fromJson(String source) =>
      CreateAccountResponse.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "CreateAccountResp(success: $success, message: $message, error: $error, user: $user)";
  }

  @override
  bool operator ==(covariant CreateAccountResponse other) {
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
