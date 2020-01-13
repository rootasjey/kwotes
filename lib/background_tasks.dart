import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/app_keys.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:path_provider/path_provider.dart';

class BackgroundTasks {
  static const name = 'memorareTask';

  static Future<Quotidian> fetchQuotidian() async {
    final HttpLink httpLink = HttpLink(
        uri: AppKeys.uri,
        headers: {
          'apikey': AppKeys.apiKey,
        },
      );

    final client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink,
        ),
    );

    try {
      final response = await client.value.query(
        QueryOptions(
          documentNode: parseString("""
            query {
              quotidians (limit: 1) {
                entries {
                  id
                  quote {
                    author {
                      name
                    }
                    id
                    name
                    references {
                      id
                      name
                    }
                    topics
                  }
                }
              }
            }
          """),
          fetchPolicy: FetchPolicy.networkOnly,
        )
      );

      return Quotidian.fromJSON(response.data['quotidians']['entries'][0]);

    } catch (e) {
      return null;
    }
  }

  static Future saveQuotidian({Quotidian quotidian}) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/quotidian';
    final file = File(path);

    final json = quotidian.toJSON();
    final str = jsonEncode(json);
    file.writeAsStringSync(str);
  }
}
