import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/button_link.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/quotes_response.dart';
import 'package:provider/provider.dart';

class AuthorPage extends StatefulWidget {
  final String authorId;
  final String authorName;
  AuthorPage({this.authorId, this.authorName});

  @override
  _AuthorPageState createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  Author author;
  List<Quote> quotes = [];
  bool isLoadingQuotes = false;
  bool isLoadQuotesError = false;
  bool isLoadCompleteQuotes = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
        options: QueryOptions(
          documentNode: parseString(queryAuthor()),
          variables: { 'id': widget.authorId },
        ),
        builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
          if (result.hasException) {
            return ErrorComponent(
              description: result.exception.graphqlErrors.first.message,
            );
          }

          if (result.loading) {
            return LoadingComponent(
              title: 'Loading ${widget.authorName}...',
              padding: EdgeInsets.all(30.0),
            );
          }

          final json = result.data['author'];
          author = Author.fromJSON(json);

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotif) {
              if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
                return false;
              }

              if (!isLoadingQuotes && !isLoadQuotesError && !isLoadCompleteQuotes) {
                fetchAuthorQuotes();
              }

              return false;
            },
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      alignment: AlignmentDirectional.center,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: InkWell(
                              onTap: () {
                                if (author.imgUrl == null) { return; }

                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Container(
                                        child: Image(image: NetworkImage(author.imgUrl),),
                                      ),
                                    );
                                  }
                                );
                              },
                              child: CircleAvatar(
                                radius: 90.0,
                                backgroundColor: ThemeColor.primary,
                                backgroundImage: author.imgUrl != null ?
                                  NetworkImage(author.imgUrl) :
                                  AssetImage('assets/images/monk.png'),
                              ),
                            )
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 30.0),
                            child: Text(
                              author.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              author.job,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 60.0),
                            child: Text(
                              author.summary,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w100,
                                height: 1.5,
                              ),
                            ),
                          ),

                          if (author.wikiUrl != null && author.wikiUrl.length > 0)
                            ButtonLink(
                              icon: Icon(IconsMore.wikipedia_w, color: Colors.white,),
                              padding: EdgeInsets.only(top: 60.0),
                              text: 'Open Wikipedia',
                              url: author.wikiUrl,
                            ),

                          if (author.url != null && author.url.length > 0)
                            ButtonLink(
                              icon: Icon(IconsMore.earth, color: Colors.white),
                              padding: EdgeInsets.only(top: 10.0),
                              text: 'Open website',
                              url: author.url,
                            ),

                          Padding(padding: EdgeInsets.only(top: 40.0),),

                          if (isLoadingQuotes)
                            LinearProgressIndicator(),

                          Divider(),

                          if (quotes.length > 0)
                            Padding(
                              padding: EdgeInsets.only(top: 40.0),
                              child: SizedBox(
                                height: 330.0,
                                child: Swiper(
                                  itemCount: quotes.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Center(
                                      child: MediumQuoteCard(quote: quotes.elementAt(index),),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    Positioned(
                      left: 0.0,
                      top: 0.0,
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back, color: Colors.black,),
                        ),
                      )
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      )
    );
  }

  void fetchAuthorQuotes() {
    final client = Provider.of<HttpClientsModel>(context).defaultClient;
    final userDataModel = Provider.of<UserDataModel>(context);
    final lang = userDataModel.data.lang;

    setState(() {
      isLoadingQuotes = true;
    });

    client.value.query(
      QueryOptions(
        documentNode: parseString(queryAuthorQuotes()),
        variables: {'authorId': widget.authorId, 'lang': lang},
      )

    ).then((QueryResult queryResult) {
      if (queryResult.hasException) {
        setState(() {
        isLoadQuotesError = true;
        });

        return;
      }

      final response = QuotesResponse.fromJSON(queryResult.data['quotesByAuthorId']);

      setState(() {
        quotes = response.entries;
      });

      setState(() {
        isLoadingQuotes = false;
        isLoadCompleteQuotes = true;
      });

    }).catchError((error) {
      setState(() {
        isLoadingQuotes = false;
        isLoadQuotesError = true;
      });
    });
  }

  String queryAuthor() {
    return """
      query (\$id: String!) {
        author (id: \$id) {
          id
          imgUrl
          job
          name
          summary
          url
          wikiUrl
        }
      }
    """;
  }

  String queryAuthorQuotes() {
    return """
      query (\$authorId: String!) {
        quotesByAuthorId (authorId: \$authorId) {
          entries {
            id
            name
            references {
              name
            }
            topics
          }
          pagination {
            limit
            nextSkip
            skip
          }
        }
      }
    """;
  }
}
