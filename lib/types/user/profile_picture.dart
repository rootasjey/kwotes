import "dart:convert";

import "package:kwotes/types/user/picture_path.dart";
import "package:kwotes/types/user/picture_url.dart";

class ProfilePicture {
  String extension;
  int size;
  PicturePath path;
  PictureUrl url;

  ProfilePicture({
    this.extension = "",
    this.size = 0,
    this.path = const PicturePath(),
    this.url = const PictureUrl(),
  });

  factory ProfilePicture.empty() {
    return ProfilePicture(
      extension: "",
      size: 0,
      path: PicturePath.empty(),
      url: PictureUrl.empty(),
    );
  }

  factory ProfilePicture.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return ProfilePicture.empty();
    }

    return ProfilePicture(
      extension: data["extension"] ?? "",
      path: PicturePath.fromJSON(data["path"]),
      url: PictureUrl.fromJSON(data["url"]),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map["extension"] = extension;
    map["size"] = size;
    map["path"] = path.toJSON();
    map["url"] = url.toJSON();

    return map;
  }

  factory ProfilePicture.fromJson(String source) =>
      ProfilePicture.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  void merge({
    String? extension,
    int? size,
    PicturePath? path,
    PictureUrl? url,
  }) {
    if (extension != null) {
      this.extension = extension;
    }

    if (size != null) {
      this.size = size;
    }

    if (path != null) {
      this.path = this.path.merge(path);
    }

    if (url != null) {
      this.url = this.url.merge(url);
    }
  }

  void update(ProfilePicture other) {
    extension = other.extension;
    size = other.size;
    path = other.path;
    url = other.url;
  }
}
