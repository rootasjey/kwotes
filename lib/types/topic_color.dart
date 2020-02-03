class TopicColor {
  final String name;
  final int decimal;
  final String hex;

  TopicColor({
    this.decimal,
    this.hex,
    this.name,
  });

  factory TopicColor.fromJSON(Map<String, dynamic> json) {
    int _decimal = json['color'];

    return TopicColor(
      decimal: _decimal,
      hex: _decimal.toRadixString(16),
      name: json['name'],
    );
  }
}
