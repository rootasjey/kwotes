import 'package:fig_style/types/reference.dart';

class ReferenceSuggestion {
  Reference reference;

  ReferenceSuggestion({
    this.reference,
  });

  factory ReferenceSuggestion.fromJSON(Map<String, dynamic> data) {
    final reference = Reference.fromJSON(data);
    return ReferenceSuggestion(reference: reference);
  }

  String getTitle() {
    String name = reference.name;

    if (reference.release != null && reference.release.original != null) {
      String year = '';

      year = reference.release.original.year.toString();

      if (reference.release.beforeJC != null) {
        year = reference.release.beforeJC ? '-$year' : year;
      }

      name = '$name ($year)';
    }

    return name;
  }
}
