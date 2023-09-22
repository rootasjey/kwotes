import "dart:convert";

/// A password class to keep track of password format requirement
/// centralized in one place.
class PasswordChecks {
  PasswordChecks({
    required this.hasMinimumLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecialCharacter,
  });

  /// True if the password has minimum length.
  final bool hasMinimumLength;

  /// True if the password has at least one uppercase character.
  final bool hasUppercase;

  /// True if the password has at least one lowercase character.
  final bool hasLowercase;

  /// True if the password has at least one digit.
  final bool hasDigit;

  /// True if the password has at least one special character.
  final bool hasSpecialCharacter;

  factory PasswordChecks.empty() {
    return PasswordChecks(
      hasMinimumLength: false,
      hasUppercase: false,
      hasLowercase: false,
      hasDigit: false,
      hasSpecialCharacter: false,
    );
  }

  PasswordChecks copyWith({
    bool? hasMinimumLength,
    bool? hasUppercase,
    bool? hasLowercase,
    bool? hasDigit,
    bool? hasSpecialCharacter,
  }) {
    return PasswordChecks(
      hasMinimumLength: hasMinimumLength ?? this.hasMinimumLength,
      hasUppercase: hasUppercase ?? this.hasUppercase,
      hasLowercase: hasLowercase ?? this.hasLowercase,
      hasDigit: hasDigit ?? this.hasDigit,
      hasSpecialCharacter: hasSpecialCharacter ?? this.hasSpecialCharacter,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "hasMinimumLength": hasMinimumLength,
      "hasUppercase": hasUppercase,
      "hasLowercase": hasLowercase,
      "hasDigit": hasDigit,
      "hasSpecialCharacter": hasSpecialCharacter,
    };
  }

  factory PasswordChecks.fromMap(Map<String, dynamic> map) {
    return PasswordChecks(
      hasMinimumLength: map["hasMinimumLength"] as bool,
      hasUppercase: map["hasUppercase"] as bool,
      hasLowercase: map["hasLowercase"] as bool,
      hasDigit: map["hasDigit"] as bool,
      hasSpecialCharacter: map["hasSpecialCharacter"] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory PasswordChecks.fromJson(String source) =>
      PasswordChecks.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return "PasswordChecks(hasMinimumLength: $hasMinimumLength, "
        "hasUppercase: $hasUppercase, hasLowercase: $hasLowercase, "
        "hasDigit: $hasDigit, hasSpecialCharacter: $hasSpecialCharacter)";
  }

  @override
  bool operator ==(covariant PasswordChecks other) {
    if (identical(this, other)) return true;

    return other.hasMinimumLength == hasMinimumLength &&
        other.hasUppercase == hasUppercase &&
        other.hasLowercase == hasLowercase &&
        other.hasDigit == hasDigit &&
        other.hasSpecialCharacter == hasSpecialCharacter;
  }

  @override
  int get hashCode {
    return hasMinimumLength.hashCode ^
        hasUppercase.hashCode ^
        hasLowercase.hashCode ^
        hasDigit.hashCode ^
        hasSpecialCharacter.hashCode;
  }
}
