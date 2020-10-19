import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/quote_row_with_actions.dart';
import 'package:memorare/components/sliver_empty_view.dart';
import 'package:memorare/components/fade_in_x.dart';
import 'package:memorare/components/fade_in_y.dart';
import 'package:memorare/components/main_app_bar.dart';
import 'package:memorare/screens/quotes_by_author_ref.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/language.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorPage extends StatefulWidget {
  final String id;
  final ScrollController scrollController;

  AuthorPage({this.id, this.scrollController});

  @override
  _AuthorPageState createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  Author author;

  bool isLoading = false;
  bool isSummaryVisible = false;
  bool hasNext = true;
  bool descending = true;
  bool isLoadingMore = false;

  DocumentSnapshot lastDoc;

  double beginY = 100.0;
  double avatarSize = 150.0;

  final limit = 30;
  final pageRoute = 'author_page';

  List<Quote> quotes = [];

  String lang = 'en';

  TextOverflow nameEllipsis = TextOverflow.ellipsis;

  @override
  void initState() {
    super.initState();
    fetch();
    fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollNotif) {
            if (scrollNotif.metrics.pixels <
                scrollNotif.metrics.maxScrollExtent) {
              return false;
            }

            if (hasNext && !isLoadingMore) {
              fetchMoreQuotes();
            }

            return false;
          },
          child: CustomScrollView(
            physics: ClampingScrollPhysics(),
            controller: widget.scrollController,
            slivers: <Widget>[
              MainAppBar(
                title: author != null ? author.name : '',
                showCloseButton: true,
                showUserMenu: false,
              ),
              infoPannel(),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Center(child: langSelectButton()),
                  ]),
                ),
              ),
              quotesListView(),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 200.0),
              ),
            ],
          )),
    );
  }

  Widget avatar() {
    if (author.urls.image != null && author.urls.image.length > 0) {
      return Material(
        elevation: 3.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: 150.milliseconds,
          width: avatarSize,
          height: avatarSize,
          child: Ink.image(
            image: NetworkImage(author.urls.image),
            width: avatarSize,
            height: avatarSize,
            fit: BoxFit.cover,
            child: InkWell(
              onHover: (isHover) {
                if (isHover) {
                  setState(() {
                    avatarSize = 160.0;
                  });

                  return;
                }

                setState(() {
                  avatarSize = 150.0;
                });
              },
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Image(
                            image: NetworkImage(author.urls.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
        ),
      );
    }

    return Material(
      elevation: 3.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Image.asset(
            'assets/images/user-${stateColors.iconExt}.png',
            width: 80.0,
          ),
        ),
        onTap: () {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Container(
                    height: 500.0,
                    width: 500.0,
                    child: Image(
                      image: AssetImage(
                        'assets/images/user-${stateColors.iconExt}.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              });
        },
      ),
    );
  }

  Widget backButton() {
    return Positioned(
        left: 40.0,
        top: 0.0,
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
        ));
  }

  Widget infoPannel() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: LoadingAnimation(
              textTitle: 'Loading author...',
            ),
          ),
        ]),
      );
    }

    if (author == null) {
      return SliverList(
        delegate: SliverChildListDelegate([
          ErrorContainer(
            message: 'Oops! There was an error while loading the reference',
            onRefresh: () => fetch(),
          ),
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        LayoutBuilder(
          builder: (context, constrains) {
            return constrains.maxWidth < 700 ? smallView() : largeView();
          },
        ),
      ]),
    );
  }

  Widget linkCircleButton({
    double delay = 0.0,
    String name,
    String url,
    String imageUrl,
  }) {
    return FadeInX(
      beginX: 50.0,
      delay: delay,
      child: Tooltip(
        message: name,
        child: Material(
          elevation: 4.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => launch(url),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                imageUrl,
                width: 30.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget emptyView() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Icon(
              Icons.sentiment_neutral,
              size: 40.0,
            ),
          ),
          Text("Sorry, no data found for the specified author"),
        ],
      ),
    );
  }

  Widget heroSmall() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Column(
        children: <Widget>[
          FadeInY(
            beginY: beginY,
            delay: 1.0,
            child: avatar(),
          ),
          FadeInY(
            beginY: beginY,
            delay: 3.0,
            child: job(),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 45.0,
            ),
            child: links(),
          ),
        ],
      ),
    );
  }

  Widget job() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Opacity(
        opacity: 0.5,
        child: Text(
          author.job,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget langSelectButton() {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: DropdownButton<String>(
        elevation: 2,
        value: lang,
        isDense: true,
        underline: Container(
          height: 0,
          color: Colors.deepPurpleAccent,
        ),
        icon: Icon(Icons.keyboard_arrow_down),
        style: TextStyle(
          color: stateColors.foreground.withOpacity(0.6),
          fontSize: 20.0,
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
        onChanged: (String newLang) {
          lang = newLang;
          fetchQuotes();
          appLocalStorage.setPageLang(lang: lang, pageRoute: pageRoute);
        },
        items: ['en', 'fr'].map((String value) {
          return DropdownMenuItem(
              value: value,
              child: Text(
                value.toUpperCase(),
              ));
        }).toList(),
      ),
    );
  }

  Widget largeView() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 120.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FadeInY(
                  beginY: beginY,
                  delay: 1.0,
                  child: avatar(),
                ),
                ControlledAnimation(
                  delay: 1.seconds,
                  duration: 1.seconds,
                  tween: Tween(begin: 0.0, end: 100.0),
                  builder: (_, value) {
                    return SizedBox(
                      width: value,
                      child: Divider(
                        thickness: 1.0,
                        height: 50.0,
                      ),
                    );
                  },
                ),
                FadeInY(
                  beginY: beginY,
                  delay: 3.0,
                  child: job(),
                ),
                FadeInY(
                  beginY: beginY,
                  delay: 3.2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: RaisedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => QuotesByAuthorRef(
                                  id: widget.id,
                                  type: SubjectType.author,
                                )));
                      },
                      color: stateColors.primary,
                      textColor: Colors.white,
                      icon: Icon(Icons.chat_bubble_outline),
                      label: Text('Related quotes'),
                    ),
                  ),
                ),
                Padding(padding: const EdgeInsets.only(top: 40.0)),
                links(),
              ],
            ),
          ),
          Expanded(
            child: summaryLarge(),
          ),
        ],
      ),
    );
  }

  Widget links() {
    final urls = author.urls;
    if (urls.areLinksEmpty()) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    return Wrap(
      spacing: 20.0,
      runSpacing: 20.0,
      children: <Widget>[
        FadeInX(
          beginX: 50.0,
          delay: 0.0,
          child: Tooltip(
            message: 'summary',
            child: Material(
              elevation: 4.0,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () =>
                    setState(() => isSummaryVisible = !isSummaryVisible),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.list_alt_outlined,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (urls.website.isNotEmpty)
          linkCircleButton(
            delay: 1.0,
            name: 'Website',
            url: urls.website,
            imageUrl: 'assets/images/world-globe.png',
          ),
        if (urls.wikipedia.isNotEmpty)
          Observer(
            builder: (_) {
              return linkCircleButton(
                delay: 1.2,
                name: 'Wikipedia',
                url: urls.wikipedia,
                imageUrl: 'assets/images/wikipedia-${stateColors.iconExt}.png',
              );
            },
          ),
        if (urls.amazon.isNotEmpty)
          linkCircleButton(
            delay: 1.4,
            name: 'Amazon',
            url: urls.amazon,
            imageUrl: 'assets/images/amazon.png',
          ),
        if (urls.facebook.isNotEmpty)
          linkCircleButton(
            delay: 1.6,
            name: 'Facebook',
            url: urls.facebook,
            imageUrl: 'assets/images/facebook.png',
          ),
        if (urls.instagram.isNotEmpty)
          linkCircleButton(
            delay: 1.7,
            name: 'Instagram',
            url: urls.instagram,
            imageUrl: 'assets/images/instagram.png',
          ),
        if (urls.netflix.isNotEmpty)
          linkCircleButton(
            delay: 1.8,
            name: 'Netflix',
            url: urls.netflix,
            imageUrl: 'assets/images/netflix.png',
          ),
        if (urls.primeVideo.isNotEmpty)
          linkCircleButton(
            delay: 2.0,
            name: 'Prime Video',
            url: urls.primeVideo,
            imageUrl: 'assets/images/prime-video.png',
          ),
        if (urls.twitch.isNotEmpty)
          linkCircleButton(
            delay: 2.2,
            name: 'Twitch',
            url: urls.twitch,
            imageUrl: 'assets/images/twitch.png',
          ),
        if (urls.twitter.isNotEmpty)
          linkCircleButton(
            delay: 2.4,
            name: 'Twitter',
            url: urls.twitter,
            imageUrl: 'assets/images/twitter.png',
          ),
        if (urls.youtube.isNotEmpty)
          linkCircleButton(
            delay: 2.6,
            name: 'Youtube',
            url: urls.youtube,
            imageUrl: 'assets/images/youtube.png',
          ),
      ],
    );
  }

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: FlatButton(
        onPressed: () {
          setState(() {
            nameEllipsis = nameEllipsis == TextOverflow.ellipsis
                ? TextOverflow.visible
                : TextOverflow.ellipsis;
          });
        },
        child: Text(
          author.name,
          overflow: nameEllipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget quotesListView() {
    if (isLoading) {
      return SliverPadding(padding: EdgeInsets.zero);
    }

    if (quotes.isEmpty) {
      return SliverEmptyView(
        title: "No quote found",
        description:
            "Sorry, we didn't found any quote in ${Language.frontend(lang)} for ${author.name}. You can try in another language.",
        onRefresh: () => fetchQuotes(),
      );
    }

    return Observer(
      builder: (context) {
        final isConnected = userState.isUserConnected;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final quote = quotes.elementAt(index);

              return QuoteRowWithActions(
                quote: quote,
                quoteId: quote.id,
                elevation: 2.0,
                isConnected: isConnected,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
              );
            },
            childCount: quotes.length,
          ),
        );
      },
    );
  }

  Widget smallView() {
    return Container(
      alignment: AlignmentDirectional.center,
      padding: const EdgeInsets.only(bottom: 60.0),
      child: Column(
        children: <Widget>[
          heroSmall(),
          if (isSummaryVisible)
            FadeInY(
              beginY: -20.0,
              endY: 0.0,
              child: summarySmall(),
            ),
        ],
      ),
    );
  }

  Widget summarySmall() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
        ),
        Divider(
          thickness: 1.0,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Opacity(
            opacity: .6,
            child: Text(
              'SUMMARY',
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 100.0,
          child: Divider(
            thickness: 1.0,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 40.0,
            vertical: 70.0,
          ),
          width: 600.0,
          child: Text(
            author.summary,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w100,
              height: 1.5,
            ),
          ),
        ),
        if (author.urls.wikipedia?.isNotEmpty)
          OutlineButton(
            onPressed: () => launch(author.urls.wikipedia),
            child: Text('More on Wikipedia'),
          ),
      ],
    );
  }

  Widget summaryLarge() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: Text(
              'SUMMARY',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
          ),
          SizedBox(
            width: 100.0,
            child: Divider(
              thickness: 1.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 60.0,
            ),
            width: 600.0,
            child: Opacity(
              opacity: 0.7,
              child: Text(
                author.summary,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w100,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (author.urls.wikipedia?.isNotEmpty)
            OutlineButton(
              onPressed: () => launch(author.urls.wikipedia),
              child: Text('More on Wikipedia'),
            )
        ],
      ),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnap = await Firestore.instance
          .collection('authors')
          .document(widget.id)
          .get();

      if (!docSnap.exists) {
        isLoading = false;
        return;
      }

      final data = docSnap.data;
      data['id'] = docSnap.documentID;

      setState(() {
        author = Author.fromJSON(data);

        nameEllipsis = author.name.length > 42
            ? TextOverflow.ellipsis
            : TextOverflow.visible;

        isLoading = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchQuotes() async {
    quotes.clear();

    try {
      final snapshot = await Firestore.instance
          .collection('quotes')
          .where('author.id', isEqualTo: widget.id)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        lastDoc = snapshot.documents.last;
        hasNext = snapshot.documents.length == limit;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void fetchMoreQuotes() async {
    if (!hasNext) {
      return;
    }

    isLoadingMore = true;

    try {
      final snapshot = await Firestore.instance
          .collection('quotes')
          .where('author.id', isEqualTo: widget.id)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        isLoadingMore = false;
        lastDoc = snapshot.documents.last;
        hasNext = snapshot.documents.length == limit;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }
}
