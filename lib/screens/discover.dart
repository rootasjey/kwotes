import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/reference_page.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/reference.dart';
import 'package:provider/provider.dart';

List<Reference> _references = [];
List<Author> _authors = [];

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  List<Reference> references = [];
  List<Author> authors = [];

  String lang = 'en';

  bool isLoading = false;
  bool hasConnection = true;
  bool hasErrorsAuthors = false;
  bool hasErrorsReferences = false;
  Error error;

  @override
  void initState() {
    super.initState();

    setState(() {
      references = _references;
      authors = _authors;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (authors.length > 0 || references.length > 0) {
      return;
    }

    DataConnectionChecker().hasConnection
    .then((_hasConnection) {
      if (!hasConnection) {
        setState(() {
          hasConnection = _hasConnection;
        });

        return;
      }

      final userData = Provider.of<UserDataModel>(context, listen: false);
      lang = (userData.data.lang != null && userData.data.lang.isNotEmpty) ?
        userData.data.lang : 'en';

      fetchRandomAuthors(lang);
      fetchRandomReferences(lang);
    });
  }

  @override
  void dispose() {
    _references = references;
    _authors = authors;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          final themeColor = Provider.of<ThemeColor>(context);
          final backgroundColor = themeColor.background;

          if (!isLoading && !hasConnection) {
            return EmptyView(
              title: 'No connection',
              description: 'The app cannot reach Internet right now.',
              onRefresh: () {
                fetchRandomAuthors(lang);
                fetchRandomReferences(lang);
              },
            );
          }

          if (isLoading) {
            return LoadingComponent(
              backgroundColor: Colors.transparent,
              color: backgroundColor,
              title: 'Loading Discover section...',
            );
          }

          if (hasErrorsAuthors && hasErrorsReferences) {
            return EmptyView(
              title: 'Discover',
              description: error != null ?
                error.toString()
                : 'An unexpected error ocurred. Please try again.',
              onRefresh: () {
                fetchRandomAuthors(lang);
                fetchRandomReferences(lang);
              },
            );
          }

          if (authors.length == 0 && references.length == 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                EmptyView(
                  title: 'Discover',
                  description: 'It is odd. There is no new data to discover at the moment 🤔. ',
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      'Try again'
                    ),
                  ),
                ),
              ],
            );
          }

          List<Widget> cards = [];

          for (var reference in references) {
            cards.add(
              discoverCard(
                title: reference.name,
                imgUrl: reference.imgUrl,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ReferencePage(
                          id: reference.id,
                          referenceName: reference.name,
                        );
                      }
                    )
                  );
                }
              )
            );
          }

          for (var author in authors) {
            cards.add(
              discoverCard(
                title: author.name,
                imgUrl: author.imgUrl,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return AuthorPage(
                          id: author.id,
                          authorName: author.name,
                        );
                      }
                    )
                  );
                }
              )
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final userData = Provider.of<UserDataModel>(context, listen: false);
              final lang = userData.data.lang;

              await fetchRandomReferences(lang);
              await fetchRandomAuthors(lang);
              return null;
            },
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Discover',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Opacity(
                    opacity: .6,
                    child: Text(
                      'Uncover new authors and references.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  )
                ),
                Divider(height: 60.0,),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: cards,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget discoverCard({String title, String imgUrl, Function onTap}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: 170,
        height: 220,
        child: Card(
          elevation: 5.0,
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap();
              }
            },
            child: Stack(
              children: <Widget>[
                if (imgUrl != null && imgUrl.length > 0)
                  Opacity(
                      opacity: .3,
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        width: 170,
                        height: 220,
                      ),
                    ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    title.length > 65 ?
                    '${title.substring(0, 64)}...' :
                    title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      )
    );
  }

  Future fetchRandomAuthors(String lang) async {
    setState(() {
      isLoading = true;
      hasErrorsAuthors = false;
    });

    hasConnection = await DataConnectionChecker().hasConnection;

    if (!hasConnection) {
      setState(() {
        isLoading = false;
        hasErrorsAuthors = true;
      });

      return;
    }

    return Queries.randomAuthors(context, lang)
      .then((authorsResp) {
        setState(() {
          authors = authorsResp.toSet().toList();
          isLoading = false;
        });
      })
      .catchError((err) {
        setState(() {
          error = err;
          hasErrorsAuthors = true;
          isLoading = false;
        });
      });
  }

  Future fetchRandomReferences(String lang) async {
    hasErrorsReferences = false;

    hasConnection = await DataConnectionChecker().hasConnection;

    if (!hasConnection) {
      setState(() {
        isLoading = false;
        hasErrorsAuthors = true;
      });

      return;
    }

    return Queries.randomReferences(context, lang)
      .then((referencesResp) {
        setState(() {
          references = referencesResp.toSet().toList();
          isLoading = false;
        });
      })
      .catchError((err) {
        error = err;
        hasErrorsReferences = true;
        isLoading = false;
      });
  }
}
