import "dart:convert";
import "dart:ui";

/// A category for a quote (e.g. "art", "biology", ...).
class Topic {
  Topic({
    required this.name,
    required this.color,
  });

  /// The name of the topic
  final String name;

  /// The color associated with the topic.
  final Color color;

  Topic copyWith({
    String? name,
    Color? color,
  }) {
    return Topic(
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "name": name,
      "color_value": color.value,
    };
  }

  factory Topic.empty() {
    return Topic(
      name: "",
      color: const Color(0x00000000),
    );
  }

  factory Topic.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Topic.empty();
    }

    return Topic(
      name: map["name"] ?? "",
      color: Color(map["color"] ?? 00000000),
    );
  }

  String toJson() => json.encode(toMap());

  factory Topic.fromJson(String source) =>
      Topic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => "Topic(name: $name, color value: ${color.value})";

  @override
  bool operator ==(covariant Topic other) {
    if (identical(this, other)) return true;
    return other.name == name && other.color == color;
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode;

  /// Converts a color to a hex string.
  /// Universal means that the value is compatible with other platforms.
  /// Since it seems that flutter adds 2 more characters to the sring.
  String toHex({bool universal = true}) {
    if (universal) {
      return "#${color.value.toRadixString(16).toUpperCase().substring(2)}";
    }

    return "#${color.value.toRadixString(16).toUpperCase()}";
  }

  String toRGBA() {
    return "RGBA(${color.red}, ${color.green}, ${color.blue}, ${color.alpha})";
  }

  String toRGB0() {
    return "RGBA(${color.red}, ${color.green}, ${color.blue}, ${color.opacity})";
  }

  int to32bitValue() {
    return color.value;
  }
}
