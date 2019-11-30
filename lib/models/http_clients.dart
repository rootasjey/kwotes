import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HttpClientsModel extends ChangeNotifier {
  ValueNotifier<GraphQLClient> _client;
  ValueNotifier<GraphQLClient> _authClient;
  Map<String, dynamic> _apiConfig;
  String _token = '';

  ValueNotifier<GraphQLClient> get client => _client;
  ValueNotifier<GraphQLClient> get authClient => _authClient;

  /// Manage multiple clients for authentication.
  ///
  /// Because cannot change headers after client creation.
  /// Consider ditching graphql_flutter?
  HttpClientsModel({Map<String, dynamic> apiConfig}) {
    _apiConfig = apiConfig;
    initClient();
  }

  /// Return auth client if a token had previously been provided.
  /// Or a non-authentified client.
  ValueNotifier<GraphQLClient> get defaultClient {
    if (_token.isEmpty) { return _client; }
    return _authClient;
  }

  /// Delete local token (on logout for example).
  void clearToken() {
    _token = '';
    _authClient = null;
    notifyListeners();
  }

  void initClient() {
    final HttpLink httpLink = HttpLink(
      uri: _apiConfig != null ? _apiConfig['url'] : '',
      headers: {
        'apikey': _apiConfig != null ? _apiConfig['apikey'] : '',
      },
    );

    _client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink,
        ),
    );
  }

  void setApiConfig(Map<String, dynamic> apiConfig) {
    _apiConfig = apiConfig;
    initClient();
  }

  /// Provide a user's token to make auth requests.
  void setToken(String token) {
    _token = token;

    final HttpLink httpLink = HttpLink(
      uri: _apiConfig['url'],
      headers: {
        'apikey': _apiConfig['apikey'],
        'token': _token,
      },
    );

    _authClient = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink,
        ),
    );

    notifyListeners();
  }
}
