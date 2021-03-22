import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class Cloud {
  static HttpsCallable fun(String name, {HttpsCallableOptions options}) {
    return FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(name);
  }
}
