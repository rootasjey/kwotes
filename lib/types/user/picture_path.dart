class PicturePath {
  final String edited;
  final String original;

  const PicturePath({
    this.edited = "",
    this.original = "",
  });

  factory PicturePath.empty() {
    return const PicturePath(
      edited: "",
      original: "",
    );
  }

  factory PicturePath.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return PicturePath.empty();
    }

    return PicturePath(
      edited: data["edited"],
      original: data["original"],
    );
  }

  PicturePath merge(PicturePath userPPPath) {
    final newEdited = userPPPath.edited;
    final newOriginal = userPPPath.original;

    return PicturePath(
      edited: newEdited.isNotEmpty ? newEdited : edited,
      original: newOriginal.isNotEmpty ? newOriginal : original,
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = {};

    data["edited"] = edited;
    data["original"] = original;

    return data;
  }
}
