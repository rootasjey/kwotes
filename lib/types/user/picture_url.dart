class PictureUrl {
  final String edited;
  final String original;

  const PictureUrl({
    this.edited = "",
    this.original = "",
  });

  factory PictureUrl.empty() {
    return const PictureUrl(
      edited: "",
      original: "",
    );
  }

  factory PictureUrl.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return PictureUrl.empty();
    }

    return PictureUrl(
      edited: data["edited"] ?? "",
      original: data["original"] ?? "",
    );
  }

  PictureUrl mergeFromValues({
    String? edited,
    String? original,
  }) {
    final newEditedValue = edited ?? this.edited;
    final newOriginalValue = original ?? this.original;

    return PictureUrl(
      edited: newEditedValue,
      original: newOriginalValue,
    );
  }

  PictureUrl merge(PictureUrl userPPUrl) {
    final String newEditedValue =
        userPPUrl.edited.isNotEmpty ? userPPUrl.edited : edited;
    final String newOriginalValue =
        userPPUrl.original.isNotEmpty ? userPPUrl.original : original;

    return PictureUrl(
      edited: newEditedValue,
      original: newOriginalValue,
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = {};

    data["edited"] = edited;
    data["original"] = original;

    return data;
  }
}
