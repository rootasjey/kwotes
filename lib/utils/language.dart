import 'package:firebase_auth/firebase_auth.dart';
import 'package:memorare/components/web/firestore_app.dart';

class Language {
  /// Current application's language.
  static String current = 'en';

  static const String en = 'en';
  static const String fr = 'fr';

  static const String english = 'English';
  static const String french = 'Français';

  static String backend(String lang) {
    switch (lang) {
      case english:
        return en;
      case french:
        return fr;
      default:
        return en;
    }
  }

  static String frontend(String lang) {
    switch (lang) {
      case en:
        return english;
      case fr:
        return french;
      default:
        return english;
    }
  }

  /// Fetch user's lang from database.
  static Future fetchLang(FirebaseUser userAuth) async {
    if (userAuth == null) { return; }

    final user = await FirestoreApp.instance
      .collection('users')
      .doc(userAuth.uid)
      .get();

    if (user.exists) {
      current = user.data()['lang'];
    }
  }
}
