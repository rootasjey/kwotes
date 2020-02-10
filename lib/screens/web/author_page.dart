import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/horizontal_card.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/router.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorPage extends StatefulWidget {
  final String id;

  AuthorPage({
    this.id,
  });

  @override
  _AuthorPageState createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  Author author;
  Quote quote;
  bool isLoading = false;

  @override
  initState() {
    super.initState();
    fetchAuthor();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget();
    }

    if (!isLoading && author == null) {
      return errorWidget();
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              // !NOTE: BlendMode does not seem to work on flutter web atm.
              // Container(
              //   color: Colors.black,
              //   height: MediaQuery.of(context).size.height,
              //   width: MediaQuery.of(context).size.width,
              //   child: Opacity(
              //     opacity: .8,
              //     child: Image.asset(
              //       'assets/images/power-of-pen-1200.png',
              //       color: Colors.grey,
              //       fit: BoxFit.cover,
              //       height: MediaQuery.of(context).size.height,
              //       width: MediaQuery.of(context).size.width,
              //       colorBlendMode: BlendMode.saturation,
              //     ),
              //   )
              // ),

              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(60.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            FluroRouter.router.pop(context);
                          },
                          icon: Icon(Icons.arrow_back,),
                        )
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 100.0),
                      child: avatar(),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text(
                        author.name,
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 100.0,
                      child: Divider(
                        thickness: 1.0,
                        height: 50.0,
                      ),
                    ),

                    Opacity(
                      opacity: .8,
                      child: Text(
                        author.job,
                        style: TextStyle(
                        ),
                      ),
                    )
                  ],
                )
              ),
            ],
          ),
        ),

        Divider(
          thickness: 1.0,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 100.0
          ),
          child: SizedBox(
            width: 600.0,
            child: Opacity(
              opacity: .7,
              child: Text(
                author.summary,
                style: TextStyle(
                  fontSize: 25.0,
                  height: 1.5,
                )
              ),
            ),
          )
        ),

        quoteWidget(),

        buttonsWidget(),

        NavBackFooter(),
      ],
    );
  }

  Widget avatar() {
    if (author.urls.image != null && author.urls.image.length > 0) {
      return CircleAvatar(
        backgroundImage: NetworkImage(author.urls.image),
        radius: 80.0,
      );
    }

    return CircleAvatar(
      backgroundImage: AssetImage('assets/images/power-of-pen-1200.png'),
      radius: 80.0,
    );
  }

  Widget loadingWidget() {
    return Column(
      children: <Widget>[
        CircularProgressIndicator(),
        Text(
          'Loading author...',
        ),
      ],
    );
  }

  Widget errorWidget() {
    return Column(
      children: <Widget>[
        Text('An error occurred :('),
      ],
    );
  }

  Widget quoteWidget() {
    if (quote == null) {
      return Padding(padding: EdgeInsets.zero,);
    }

    return Container(
      child: Column(
        children: <Widget>[
          Divider(
            thickness: 1.0,
          ),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'QUOTES'
              ),
            )
          ),

          SizedBox(
            width: 100,
            child: Divider(thickness: 1.0,)
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 100.0),
            child: HorizontalCard(
              quoteId: quote.id,
              quoteName: quote.name,
              referenceId: quote.mainReference.id,
              referenceName: quote.mainReference.name,
            ),
          ),

          Divider(
            thickness: 1.0,
          ),
        ],
      ),
    );
  }

  Widget buttonsWidget() {
    final children = <Widget>[];

    if (author.urls.wikipedia != null &&
      author.urls.wikipedia.length > 0) {

      children.add(
        RaisedButton(
          onPressed: () {
            launch(author.urls.wikipedia);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 25.0),
                  child: Icon(
                    IconsMore.wikipedia_w,
                    size: 15.0,
                  ),
                ),
                Text(
                  'Wikipedia',
                )
              ],
            ),
          )
        )
      );
    }

    if (author.urls.website != null &&
      author.urls.website.length > 0) {

      children.add(
        RaisedButton(
          onPressed: () {
            launch(author.urls.website);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 25.0),
                  child: Icon(
                    IconsMore.earth,
                    size: 15.0,
                  ),
                ),
                Text(
                  'Website',
                )
              ],
            ),
          )
        )
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  void fetchAuthor() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await FirestoreApp.instance
        .collection('authors')
        .doc(widget.id)
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final _author = Author.fromJSON(doc.data());

      setState(() {
        author = _author;
        isLoading = false;
      });

      fetchQuote();

    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchQuote() async {
    if (author == null) { return; }

    try {
      final snapshot = await FirestoreApp.instance
        .collection('quotes')
        .where('author.name', '==', author.name)
        .limit(1)
        .get();

      if (snapshot.empty) { return; }

      snapshot.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        quote = Quote.fromJSON(data);
      });

      setState(() {});

    } catch (error) {
      print(error);
    }
  }
}
