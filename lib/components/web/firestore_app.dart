import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;

class FirestoreApp {
  static final fs.Firestore instance = fb.firestore();
}
