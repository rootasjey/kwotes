// ignore_for_file: public_member_api_docs, sort_constructors_first
import "dart:convert";

import "package:kwotes/types/cloud_fun_error.dart";
import "package:kwotes/types/user/user_firestore.dart";

/// Cloud function response.
class CloudFunResponse {
  CloudFunResponse({
    this.error,
    this.user,
    this.success = false,
  });

  /// Whether the request was successful.
  bool success;

  /// Cloud function error.
  final CloudFunError? error;

  /// User who performed the action.
  final UserFirestore? user;

  factory CloudFunResponse.fromMap(Map<dynamic, dynamic> data) {
    return CloudFunResponse(
      success: data["success"] ?? true,
      user: UserFirestore.fromMap(data["user"]),
      error: CloudFunError.fromMap(data["error"]),
    );
  }

  CloudFunResponse copyWith({
    CloudFunError? error,
    UserFirestore? user,
  }) {
    return CloudFunResponse(
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "error": error?.toMap(),
      "user": user?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory CloudFunResponse.fromJson(String source) => CloudFunResponse.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() => "CloudFunResponse(error: $error, user: $user)";

  @override
  bool operator ==(covariant CloudFunResponse other) {
    if (identical(this, other)) return true;

    return other.error == error && other.user == user;
  }

  @override
  int get hashCode => error.hashCode ^ user.hashCode;
}
