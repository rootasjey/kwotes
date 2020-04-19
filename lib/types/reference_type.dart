class ReferenceType {
  String primary;
  String secondary;

  ReferenceType({
    this.primary = '',
    this.secondary = '',
  });

  factory ReferenceType.fromJSON(Map<String, dynamic> json) {
    return ReferenceType(
      primary: json['primary'] ?? '',
      secondary: json['secondary'] ?? '',
    );
  }
}
