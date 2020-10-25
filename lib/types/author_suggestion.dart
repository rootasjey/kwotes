import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/reference.dart';

class AuthorSuggestion {
  final Author author;
  Reference reference;

  AuthorSuggestion({
    this.author,
    this.reference,
  });

  factory AuthorSuggestion.fromJSON(Map<String, dynamic> json) {
    final author = Author.fromJSON(json);
    return AuthorSuggestion(author: author);
  }

  String getTitle() {
    String name = author.name;

    if (reference != null) {
      String year = '';

      if (reference.release != null && reference.release.original != null) {
        year = reference.release.original.year.toString();
        year = reference.release.beforeJC ? '-$year' : year;
      }

      name = '$name (${reference.name} — $year)';
    } else {
      final bornDate = author.born?.date;
      final deathDate = author.death?.date;

      String bornStr = '';
      String deathStr = '';

      if (bornDate != null) {
        bornStr =
            author.born.beforeJC ? '-${bornDate.year}' : '${bornDate.year}';
      }

      if (deathDate != null) {
        deathStr =
            author.death.beforeJC ? '-${deathDate.year}' : '${deathDate.year}';
      }

      if (bornStr.isNotEmpty || deathStr.isNotEmpty) {
        name += ' ($bornStr — $deathStr)';
      }
    }

    return name;
  }

  String getSubtitle() {
    return reference != null ? reference.name : '';
  }

  void parseReferenceJSON(Map<String, dynamic> json) {
    final newReference = Reference.fromJSON(json);
    this.reference = newReference;
  }
}
