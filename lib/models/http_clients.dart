import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';

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
  void setToken({String token, BuildContext context}) {
    _token = token;

    final HttpLink httpLink = HttpLink(
      uri: _apiConfig['url'],
      headers: {
        'apikey': _apiConfig['apikey'],
        'token': _token,
      },
    );

    final errorLink = ErrorLink(
      errorHandler: (response) {
        if (response.exception.graphqlErrors == null) {
          return null;
        }

        final isJwtExpired = response.exception.graphqlErrors
          .any((error) {
            return error.message.contains('jwt expired');
          });

        if (!isJwtExpired) { return null; }

        return ErrorComponent
          .trySignin(context)
          .then((tryResponse) {
            if (tryResponse.hasErrors) {
              return null;
            }

            return response.operation;
          });
      }
    );

    _authClient = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: errorLink.concat(httpLink),
        ),
    );

    notifyListeners();
  }
}
