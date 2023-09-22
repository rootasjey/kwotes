// ignore_for_file: public_member_api_docs, sort_constructors_first
import "dart:convert";

import "package:cloud_functions/cloud_functions.dart";

/// Cloud function error.
class CloudFunError {
  CloudFunError({
    this.code = "",
    this.details = "",
    this.message = "",
  });

  /// Error code.
  final String code;

  /// Error details.
  final String details;

  /// Error message.
  final String message;

  /// Create an error from an exception.
  factory CloudFunError.fromException(FirebaseFunctionsException exception) {
    final dynamic details = exception.details;

    final String code = details != null ? exception.details["code"] : "";
    final String message = details != null ? details["message"] : "";

    return CloudFunError(
      code: code,
      message: message,
      details: "",
    );
  }

  /// Create an empty error.
  factory CloudFunError.empty() {
    return CloudFunError(
      message: "",
      code: "",
      details: "",
    );
  }

  /// Create an error from a map.
  factory CloudFunError.fromMap(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return CloudFunError.empty();
    }

    return CloudFunError(
      message: data["message"] ?? "",
      code: data["code"] ?? "",
      details: data["details"] ?? "",
    );
  }

  /// Create an error from a message (string).
  factory CloudFunError.fromMessage(String message) {
    return CloudFunError(
      message: message,
      code: "",
      details: "",
    );
  }

  CloudFunError copyWith({
    String? code,
    String? details,
    String? message,
  }) {
    return CloudFunError(
      code: code ?? this.code,
      details: details ?? this.details,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "code": code,
      "details": details,
      "message": message,
    };
  }

  String toJson() => json.encode(toMap());

  factory CloudFunError.fromJson(String source) => CloudFunError.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() =>
      "CloudFunError(code: $code, details: $details, message: $message)";

  @override
  bool operator ==(covariant CloudFunError other) {
    if (identical(this, other)) return true;

    return other.code == code &&
        other.details == details &&
        other.message == message;
  }

  @override
  int get hashCode => code.hashCode ^ details.hashCode ^ message.hashCode;
}
