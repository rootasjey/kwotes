import 'package:fig_style/types/author.dart';
import 'package:fig_style/types/reference.dart';

class AuthorSuggestion {
  final Author author;
  Reference reference;

  AuthorSuggestion({
    this.author,
    this.reference,
  });

  factory AuthorSuggestion.fromJSON(Map<String, dynamic> data) {
    final author = Author.fromJSON(data);
    return AuthorSuggestion(author: author);
  }

  String getTitle() {
    String name = author.name;

    if (reference != null) {
      String year = '';

      if (reference.release != null && reference.release.original != null) {
        year = reference.release.original.year.toString();

        if (reference.release.beforeJC != null) {
          year = reference.release.beforeJC ? '-$year' : year;
        }
      }

      name = '$name (${reference.name} — $year)';
    } else {
      final bornDate = author.born?.date;
      final deathDate = author.death?.date;

      String bornStr = '';
      String deathStr = '';

      if (bornDate != null) {
        bornStr = "${bornDate.year}";

        if (author.born.beforeJC != null) {
          bornStr = author.born.beforeJC ? '-$bornStr' : '$bornStr';
        }
      }

      if (deathDate != null) {
        deathStr = "${deathDate.year}";

        if (author.death.beforeJC != null) {
          deathStr = author.death.beforeJC ? '-$deathStr' : '$deathStr';
        }
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
