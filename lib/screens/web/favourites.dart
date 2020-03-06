import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/empty_flat_card.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Favourites extends StatefulWidget {
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  bool isLoading = false;
  bool isLoadingMore = false;

  List<Quote> quotes = [];

  FirebaseUser userAuth;

  var lastDoc;

  @override
  initState() {
    super.initState();
    fetchFavQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),
        body(),
        NavBackFooter(),
      ],
    );
  }

  Widget body() {
    if (isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Loading your favourites...',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!isLoading && quotes.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height - 300.0,
        child:  EmptyFlatCard(
          onPressed: () => fetchFavQuotes(),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Opacity(
            opacity: .6,
            child: Text(
              'Favourites',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          )
        ),

        listQuotes(),
      ],
    );
  }

  Widget listQuotes() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100.0,
      child: ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (BuildContext context, int index) {
          final quote = quotes.elementAt(index);
          final topicColor = appTopicsColors.find(quote.topics.first);

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ),
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    FluroRouter.router.navigateTo(
                      context,
                      QuotePageRoute.replaceFirst(':id', quote.id),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: 400.0,
                      child: Text(
                        quote.name,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: 100.0,
                  child: Divider(
                    color: topicColor != null ?
                      Color(topicColor.decimal) :
                      Colors.white,
                    thickness: 2.0,
                    height: 40.0,
                  )
                ),

                userActions(quote),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget userActions(Quote quote) {
    return PopupMenuButton<String>(
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.more_horiz)
      ),
      onSelected: (value) {
        switch (value) {
          case 'remove':
            removeFav(quote);
            break;
          case 'share':
            shareTwitter(quote: quote);
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: 'remove',
          child: ListTile(
            leading: Icon(Icons.remove_circle),
            title: Text('Remove'),
          )
        ),
        PopupMenuItem(
          value: 'share',
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
          )
        ),
      ],
    );
  }

  void fetchFavQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      userAuth = userAuth ?? await FirebaseAuth.instance.currentUser();

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
      }

      final snapshot = await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .collection('favourites')
        .limit(30)
        .get();

      if (snapshot.empty) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      snapshot.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        isLoading = false;
      });

    } catch (error) {
      debugPrint(error.toString());

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        message: "There was an issue while fetching your favourites.",
      )..show(context);
    }
  }

  Future removeFav(Quote quote) async {
    final index = quotes.indexOf(quote);

    setState(() { // optimistic
      quotes.removeAt(index);
    });

    try {
      final result = await removeFromFavourites(quote: quote);

      if (!result) {
        setState(() {
          quotes.insert(index, quote);
        });
      }

    } catch (error) {
      debugPrint(error.toString());

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        message: "There was an issue while removing the quote from your favourites.",
      )
      ..show(context);

      if (!quotes.contains(quote)) {
        setState(() {
          quotes.insert(index, quote);
        });
      }
    }
  }
}
