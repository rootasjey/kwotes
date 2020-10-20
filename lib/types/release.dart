class Release {
  /// Original release.
  DateTime original;

  Release({
    this.original,
  });

  factory Release.fromJSON(Map<String, dynamic> json) {
    return Release(
      original: json['original'],
    );
  }
}
