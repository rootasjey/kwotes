import "dart:ui";
import "dart:convert";

class Tag {
  /// A tag for a quote (e.g. "Spooky night", ...).
  Tag({
    required this.name,
    required this.color,
  });

  /// The name of the tag.
  final String name;

  /// The color associated with this tag.
  final Color color;

  Tag copyWith({
    String? name,
    Color? color,
  }) {
    return Tag(
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "name": name,
      "hex_color": color.value,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      name: map["name"] ?? "",
      color: Color(int.parse(map["hex_color"].replaceAll("#", "0xFF"))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Tag.fromJson(String source) =>
      Tag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => "Category(name: $name, color: $color)";

  @override
  bool operator ==(covariant Tag other) {
    if (identical(this, other)) return true;

    return other.name == name && other.color == color;
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode;
}
