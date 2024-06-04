import "package:cloud_firestore/cloud_firestore.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils/app_state.dart";
import "package:kwotes/globals/utils/calligraphy.dart";
import "package:kwotes/globals/utils/graphic.dart";
import "package:kwotes/globals/utils/lambda.dart";
import "package:kwotes/globals/utils/linguistic.dart";
import "package:kwotes/globals/utils/measurements.dart";
import "package:kwotes/globals/utils/monetization.dart";
import "package:kwotes/globals/utils/passage.dart";
import "package:kwotes/globals/utils/search.dart";
import "package:kwotes/globals/utils/tic_tac.dart";
import "package:kwotes/globals/utils/vault.dart";
import "package:kwotes/types/firestore/query_doc_snap_map.dart";
import "package:kwotes/types/firestore/query_snap_map.dart";
import "package:kwotes/types/topic.dart";

class Utils {
  /// Date and time interface.
  static const tictac = TicTac();

  /// Typography interface.
  static const calligraphy = Calligraphy();

  /// Everything about size interface.
  static const measurements = Measurements();

  /// Navigation interface.
  static const passage = Passage();

  /// Visual interface (e.g. animation).
  static const graphic = Graphic();

  /// Language interface.
  static const linguistic = Linguistic();

  /// Cloud functions interface.
  static const lambda = Lambda();

  /// Search interface.
  static final search = SearchApi();

  /// Monetization interface.
  static const monetization = Monetization();

  /// Application state interface.
  static final state = AppState();

  /// Local storage interface.
  static final vault = Vault();

  static String getStringWithUnit(int usedBytes) {
    if (usedBytes < 1000) {
      return "$usedBytes bytes";
    }

    if (usedBytes < 1000000) {
      return "${usedBytes / 1000} KB";
    }

    if (usedBytes < 1000000000) {
      return "${usedBytes / 1000000} MB";
    }

    if (usedBytes < 1000000000000) {
      return "${usedBytes / 1000000000} GB";
    }

    if (usedBytes < 1000000000000000) {
      return "${usedBytes / 1000000000000} TB";
    }

    return "${usedBytes / 1000000000000000} PB";
  }

  static Future<void> fetchTopicsColors() async {
    final QuerySnapMap snapshot =
        await FirebaseFirestore.instance.collection("topics").get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final List<Topic> list = [];

    for (final QueryDocSnapMap doc in snapshot.docs) {
      final topicColor = Topic.fromMap(doc.data());
      list.add(topicColor);
    }

    Constants.colors.topics = list;
  }
}
