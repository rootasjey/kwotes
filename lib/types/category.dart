import "dart:ui";
import "dart:convert";

class Category {
  /// A category for a quote (e.g. "Music", "Movies", "Series" ...).
  Category({
    required this.name,
    required this.color,
  });

  /// The name of the category.
  final String name;

  /// The color associated with this category.
  final Color color;

  Category copyWith({
    String? name,
    Color? color,
  }) {
    return Category(
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

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      name: map["name"] ?? "",
      color: Color(int.parse(map["hex_color"].replaceAll("#", "0xFF"))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => "Category(name: $name, color: $color)";

  @override
  bool operator ==(covariant Category other) {
    if (identical(this, other)) return true;

    return other.name == name && other.color == color;
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode;
}
