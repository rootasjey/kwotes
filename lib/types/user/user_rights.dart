import "dart:convert";

class UserRights {
  const UserRights({
    this.canManageData = false,
    this.canManageQuotes = false,
    this.canManageAuthors = false,
    this.canManageReferences = false,
    this.canManageSettings = false,
    this.canManageUsers = false,
    this.canProposeQuote = false,
  });

  /// Current user can manage app data if true.
  final bool canManageData;

  /// Current user can manage (add, remove, edit) quotes if true.
  final bool canManageQuotes;

  /// Current user can manage (add, remove, edit) authors if true.
  final bool canManageAuthors;

  /// Current user can manage (add, remove, edit) references if true.
  final bool canManageReferences;

  /// Current user can manage (add, remove, edit) app settings if true.
  final bool canManageSettings;

  /// Current user can manage (add, remove, edit) users if true.
  final bool canManageUsers;

  /// Current user can propose a quote if true.
  final bool canProposeQuote;

  /// User's right key prefix used to store document in Firestore.
  static String prefixKey = "user:";

  UserRights copyWith({
    bool? canManageData,
    bool? canManageQuotes,
    bool? canManageAuthors,
    bool? canManageReferences,
    bool? canManageSettings,
    bool? canManageUsers,
    bool? canProposeQuote,
  }) {
    return UserRights(
      canManageData: canManageData ?? this.canManageData,
      canManageQuotes: canManageQuotes ?? this.canManageQuotes,
      canManageAuthors: canManageAuthors ?? this.canManageAuthors,
      canManageReferences: canManageReferences ?? this.canManageReferences,
      canManageSettings: canManageSettings ?? this.canManageSettings,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canProposeQuote: canProposeQuote ?? this.canProposeQuote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "${prefixKey}manage_data": canManageData,
      "${prefixKey}manage_quotes": canManageQuotes,
      "${prefixKey}manage_authors": canManageAuthors,
      "${prefixKey}manage_references": canManageReferences,
      "${prefixKey}manage_settings": canManageSettings,
      "${prefixKey}manage_users": canManageUsers,
      "${prefixKey}propose_quotes": canProposeQuote,
    };
  }

  factory UserRights.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const UserRights();
    }

    return UserRights(
      canManageData: map["${prefixKey}manage_data"] ?? false,
      canManageQuotes: map["${prefixKey}manage_quotes"] ?? false,
      canManageAuthors: map["${prefixKey}manage_authors"] ?? false,
      canManageReferences: map["${prefixKey}manage_references"] ?? false,
      canManageSettings: map["${prefixKey}manage_settings"] ?? false,
      canManageUsers: map["${prefixKey}manage_users"] ?? false,
      canProposeQuote: map["${prefixKey}propose_quotes"] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRights.fromJson(String source) =>
      UserRights.fromMap(json.decode(source));

  @override
  String toString() => "UserRights(manageData: $canManageData, "
      "manageQuotes: $canManageQuotes, manageAuthors: $canManageAuthors, "
      "manageReferences: $canManageReferences, manageSettings: $canManageSettings, "
      "manageUsers: $canManageUsers, proposeQuote: $canProposeQuote);";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserRights &&
        other.canManageData == canManageData &&
        other.canManageQuotes == canManageQuotes &&
        other.canManageAuthors == canManageAuthors &&
        other.canManageReferences == canManageReferences &&
        other.canManageSettings == canManageSettings &&
        other.canManageUsers == canManageUsers &&
        other.canProposeQuote == canProposeQuote;
  }

  @override
  int get hashCode =>
      canManageData.hashCode ^
      canManageQuotes.hashCode ^
      canManageAuthors.hashCode ^
      canManageReferences.hashCode ^
      canManageSettings.hashCode ^
      canManageUsers.hashCode ^
      canProposeQuote.hashCode;
}
