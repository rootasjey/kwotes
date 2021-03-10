/// From which reference this object is from.
class FromReference {
  /// Reference's id to which the author belongs to.
  String id;

  /// Reference's name.
  /// This property doesn't exist in Firestore,
  /// and is used mainly when editing author
  /// (better indication to which reference the author belongs to).
  String name;

  FromReference({
    this.id = '',
    this.name = '',
  });

  factory FromReference.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return FromReference();
    }

    return FromReference(
      id: data['id'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();
    data['id'] = id;
    return data;
  }
}
