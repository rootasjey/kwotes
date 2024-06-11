import "dart:convert";

import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";
import "package:kwotes/types/user/social_links.dart";
import "package:kwotes/types/user/profile_picture.dart";
import "package:kwotes/types/user/user_metrics.dart";
import "package:kwotes/types/user/user_rights.dart";

/// User model from Firestore.
/// Main user data of the app.
class UserFirestore {
  UserFirestore({
    required this.id,
    required this.profilePicture,
    required this.socialLinks,
    required this.createdAt,
    required this.metrics,
    this.plan = EnumUserPlan.free,
    this.email = "anonymous@kwotes.fr",
    this.job = "Ghosting",
    this.language = "en",
    this.location = "Nowhere",
    this.name = "Anonymous",
    this.nameLowerCase = "anonymous",
    this.bio = "An anonymous user ghosting decent people.",
    this.updatedAt,
    this.rights = const UserRights(),
  });

  /// When this account was created.
  final DateTime createdAt;

  /// Last time this account was updated (any field update).
  final DateTime? updatedAt;

  /// User plan (e.g. free, premium).
  final EnumUserPlan plan;

  /// Profile picture.
  final ProfilePicture profilePicture;

  /// User's email.
  final String email;

  /// Unique identifier.
  final String id;

  /// What they do for a living.
  final String job;

  /// Default language (speaking/display language).
  final String language;

  /// Where they live.
  final String location;

  /// User's name.
  final String name;

  /// User's name in lower case to check unicity.
  final String nameLowerCase;

  /// What this user is allowed to do.
  final UserRights rights;

  /// About this user.
  final String bio;

  /// Public links to find more about this user.
  final SocialLinks socialLinks;

  /// Metrics for this user.
  final UserMetrics metrics;

  UserFirestore copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    String? email,
    String? job,
    String? language,
    String? location,
    String? name,
    String? nameLowerCase,
    String? bio,
    ProfilePicture? profilePicture,
    UserRights? rights,
    SocialLinks? socialLinks,
    EnumUserPlan? plan,
    UserMetrics? metrics,
  }) {
    return UserFirestore(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      email: email ?? this.email,
      job: job ?? this.job,
      language: language ?? this.language,
      location: location ?? this.location,
      name: name ?? this.name,
      nameLowerCase: nameLowerCase ?? this.nameLowerCase,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      rights: rights ?? this.rights,
      socialLinks: socialLinks ?? this.socialLinks,
      plan: plan ?? this.plan,
      metrics: metrics ?? this.metrics,
    );
  }

  factory UserFirestore.empty() {
    return UserFirestore(
      createdAt: DateTime.now(),
      email: "anonymous@rootasjey.dev",
      id: "",
      job: "Ghosting",
      language: "en",
      location: "Nowhere",
      name: "Anonymous",
      nameLowerCase: "anonymous",
      profilePicture: ProfilePicture.empty(),
      bio: "An anonymous user ghosting decent people.",
      updatedAt: DateTime.now(),
      socialLinks: SocialLinks.empty(),
      rights: const UserRights(),
      plan: EnumUserPlan.free,
      metrics: UserMetrics.empty(),
    );
  }

  factory UserFirestore.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserFirestore.empty();
    }

    return UserFirestore(
      bio: map["bio"] ?? "An anonymous user ghosting decent people",
      createdAt: Utils.tictac.fromFirestore(map["created_at"]),
      email: map["email"] ?? "",
      id: map["id"] ?? "",
      job: map["job"] ?? "Ghosting",
      language: map["language"] ?? "en",
      location: map["location"] ?? "Nowhere",
      name: map["name"] ?? "Anonymous",
      nameLowerCase: map["name_lower_case"] ?? "anonymous",
      profilePicture: ProfilePicture.fromMap(map["profile_picture"]),
      updatedAt: Utils.tictac.fromFirestore(map["updated_at"]),
      socialLinks: SocialLinks.fromMap(map["social_links"]),
      rights: UserRights.fromMap(map["rights"]),
      metrics: UserMetrics.fromMap(map["metrics"]),
    );
  }

  factory UserFirestore.fromJson(String source) =>
      UserFirestore.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap({bool withAllFields = false}) {
    Map<String, dynamic> map = {};

    if (withAllFields) {
      map["email"] = email;
      map["name"] = name;
      map["name_lower_case"] = nameLowerCase;
    }

    map["job"] = job;
    map["language"] = language;
    map["location"] = location;
    map["profile_picture"] = profilePicture.toMap();
    map["bio"] = bio;
    map["updated_at"] = DateTime.now();
    map["social_links"] = socialLinks.toMap();
    map["rights"] = rights.toMap();

    return map;
  }

  @override
  String toString() {
    return "UserFirestore(createdAt: $createdAt, email: $email,"
        " id: $id, job: $job, language: $language, location: $location, "
        "name: $name, nameLowerCase: $nameLowerCase, "
        "profilePicture: $profilePicture, "
        "bio: $bio, "
        "rights: $rights, "
        "plan: $plan, "
        "updatedAt: $updatedAt, socialLinks: $socialLinks)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserFirestore &&
        other.bio == bio &&
        other.createdAt == createdAt &&
        other.email == email &&
        other.id == id &&
        other.job == job &&
        other.language == language &&
        other.location == location &&
        other.metrics == metrics &&
        other.name == name &&
        other.nameLowerCase == nameLowerCase &&
        other.plan == plan &&
        other.profilePicture == profilePicture &&
        other.rights == rights &&
        other.socialLinks == socialLinks &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        bio.hashCode ^
        email.hashCode ^
        job.hashCode ^
        id.hashCode ^
        language.hashCode ^
        location.hashCode ^
        metrics.hashCode ^
        name.hashCode ^
        nameLowerCase.hashCode ^
        profilePicture.hashCode ^
        rights.hashCode ^
        plan.hashCode ^
        updatedAt.hashCode ^
        socialLinks.hashCode;
  }

  /// Return user's profile picture if any.
  /// If [placeholder] is `true`, the method will return
  /// a default picture if the user hasn't set one.
  String getProfilePicture() {
    final String edited = profilePicture.url.edited;

    if (edited.isNotEmpty) {
      return edited;
    }

    final String original = profilePicture.url.original;
    return original;
  }
}
