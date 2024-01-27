import "dart:convert";

class ActionReturnValue {
  ActionReturnValue({
    required this.success,
    this.reason = "",
    this.error,
  });

  /// Whether the action was successful.
  final bool success;

  /// Error if any.
  final Object? error;

  /// A string to briefly describe the action result if any.
  final String reason;

  ActionReturnValue copyWith({
    bool? success,
    Object? error,
    String? reason,
  }) {
    return ActionReturnValue(
      success: success ?? this.success,
      error: error ?? this.error,
      reason: reason ?? this.reason,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "success": success,
      "error": error?.toString(),
      "reason": reason,
    };
  }

  factory ActionReturnValue.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ActionReturnValue(
        success: false,
        reason: "",
      );
    }

    return ActionReturnValue(
      success: map["success"] ?? false,
      error: map["error"],
      reason: map["reason"] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory ActionReturnValue.fromJson(String source) =>
      ActionReturnValue.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() =>
      "ActionReturnValue(success: $success, error: $error, reason: $reason)";

  @override
  bool operator ==(covariant ActionReturnValue other) {
    if (identical(this, other)) return true;

    return other.success == success &&
        other.error == error &&
        other.reason == reason;
  }

  @override
  int get hashCode => success.hashCode ^ error.hashCode ^ reason.hashCode;
}
