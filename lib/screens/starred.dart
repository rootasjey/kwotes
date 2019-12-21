import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queriesOperations.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotes_response.dart';
import 'package:provider/provider.dart';

class Starred extends StatefulWidget {
  @override
  _StarredState createState() => _StarredState();
}

class _StarredState extends State<Starred> {
  int limit = 10;
  int order = 1;
  int skip = 0;
  List<Quote> quotes = [];

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ThemeColor>(context).accent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'favorites',
          style: TextStyle(
            color: color,
            fontSize: 30.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: color,),
        ),
      ),
      body: Query(
        options: QueryOptions(
          documentNode: QueriesOperations.starred,
          variables: {'limit': limit, 'order': order, 'skip': skip}
        ),
        builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
          if (result.hasException) {
            final exception = result.exception;

            return ErrorComponent(
              description: exception.graphqlErrors.first.message,
              title: 'Liked',
            );
          }

          if (result.loading) {
            return LoadingComponent(
              title: 'Loading liked quotes',
              padding: EdgeInsets.all(30.0),
            );
          }

          final quotesResponse = QuotesResponse.fromJSON(result.data['userData']['starred']);
          quotes = quotesResponse.entries;

          List<Widget> quotesCards = [];

          for (var quote in quotes) {
            quote.starred = true;
            quotesCards.add(
              MediumQuoteCard(
                quote: quote,
                onUnlike: () async {
                  final booleanMessage = await UserMutations.unstar(context, quote.id);

                  setState(() {
                    quotes.removeWhere((q) => q.id == quote.id );
                  });

                  Flushbar(
                    duration: Duration(seconds: 2),
                    backgroundColor: booleanMessage.boolean ?
                      ThemeColor.success :
                      ThemeColor.error,
                    message: booleanMessage.boolean ?
                      'This quote has been removed from your loved ones.':
                      booleanMessage.message,
                  )..show(context);
                },
              )
            );
          }

          return ListView(
            padding: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
            children: quotesCards,
          );
        },
      ),
    );
  }
}
