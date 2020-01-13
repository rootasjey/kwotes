import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';

class HttpClientsModel extends ChangeNotifier {
  ValueNotifier<GraphQLClient> _client;
  ValueNotifier<GraphQLClient> _authClient;
  String _token = '';
  String _uri = '';
  String _apiKey = '';

  ValueNotifier<GraphQLClient> get client => _client;
  ValueNotifier<GraphQLClient> get authClient => _authClient;

  /// Manage multiple clients for authentication.
  ///
  /// Because cannot change headers after client creation.
  /// Consider ditching graphql_flutter?
  HttpClientsModel({String uri = '', String apiKey = ''}) {
    _uri = uri;
    _apiKey = apiKey;
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
      uri: _uri,
      headers: {
        'apikey': _apiKey,
      },
    );

    _client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink,
        ),
    );
  }

  /// Provide a user's token to make auth requests.
  void setToken({String token, BuildContext context}) {
    _token = token;

    final HttpLink httpLink = HttpLink(
      uri: _uri,
      headers: {
        'apikey': _apiKey,
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
