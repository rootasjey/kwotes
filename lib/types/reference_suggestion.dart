import 'package:figstyle/types/reference.dart';

class ReferenceSuggestion {
  Reference reference;

  ReferenceSuggestion({
    this.reference,
  });

  factory ReferenceSuggestion.fromJSON(Map<String, dynamic> json) {
    final reference = Reference.fromJSON(json);
    return ReferenceSuggestion(reference: reference);
  }

  String getTitle() {
    String name = reference.name;

    if (reference.release != null && reference.release.original != null) {
      String year = '';

      year = reference.release.original.year.toString();
      year = reference.release.beforeJC ? '-$year' : year;

      name = '$name ($year)';
    }

    return name;
  }
}
