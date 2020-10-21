class Release {
  /// Original release.
  DateTime original;
  bool beforeJC;

  Release({
    this.original,
    this.beforeJC,
  });

  factory Release.fromJSON(Map<String, dynamic> json) {
    return Release(
      original: json['original'],
      beforeJC: json['beforeJC'],
    );
  }
}
