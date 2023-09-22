import "package:algolia/algolia.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

class SearchApi {
  SearchApi();

  final Algolia algolia = Algolia.init(
    applicationId: dotenv.get("ALGOLIA_APP_ID"),
    apiKey: dotenv.get("ALGOLIA_SEARCH_API_KEY"),
  );
}
