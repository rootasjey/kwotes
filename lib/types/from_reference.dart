/// From which reference this object is from.
class FromReference {
  /// Object id (Firestore)
  final String id;

  FromReference({
    this.id = '',
  });

  factory FromReference.fromJSON(Map<String, dynamic> json) {
    return FromReference(
      id: json['id'] ?? '',
    );
  }
}
