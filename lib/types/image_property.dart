import 'package:figstyle/types/image_credits.dart';

class ImageProperty {
  ImageCredits credits;

  ImageProperty({this.credits});

  factory ImageProperty.empty() {
    return ImageProperty(
      credits: ImageCredits.empty(),
    );
  }

  factory ImageProperty.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return ImageProperty.empty();
    }

    return ImageProperty(
      credits: ImageCredits.fromJSON(data['credits']),
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['credits'] = credits.toJSON();

    return data;
  }
}
