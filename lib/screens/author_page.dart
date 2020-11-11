import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/sliver_empty_view.dart';
import 'package:figstyle/components/fade_in_x.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/language.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorPage extends StatefulWidget {
  final String id;
  final ScrollController scrollController;

  AuthorPage({@required this.id, this.scrollController});

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

  double beginY = 20.0;
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
              DesktopAppBar(
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
    final isImageUrlOk =
        author.urls.image != null && author.urls.image.length > 0;

    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0.0,
      closedBuilder: (_, openContainer) {
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
              image: isImageUrlOk
                  ? NetworkImage(author.urls.image)
                  : AssetImage('assets/images/user-m.png'),
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              child: InkWell(
                onTap: openContainer,
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
              ),
            ),
          ),
        );
      },
      openBuilder: (context, callback) {
        return Container(
          height: 800.0,
          width: 600.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Image(
                  image: isImageUrlOk
                      ? NetworkImage(author.urls.image)
                      : AssetImage('assets/images/user-m.png'),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 40.0,
                right: 20.0,
                child: CircleButton(
                    icon: Icon(Icons.close, color: stateColors.secondary),
                    onTap: () => Navigator.of(context).pop()),
              ),
            ],
          ),
        );
      },
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
            return authorPanel();
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
                color: stateColors.foreground,
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
            delay: 1.0,
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
          appStorage.setPageLang(lang: lang, pageRoute: pageRoute);
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

  Widget links() {
    final urls = author.urls;
    if (urls.areLinksEmpty()) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Wrap(
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
              delay: 0.1,
              name: 'Website',
              url: urls.website,
              imageUrl: 'assets/images/world-globe.png',
            ),
          if (urls.wikipedia.isNotEmpty)
            linkCircleButton(
              delay: 0.2,
              name: 'Wikipedia',
              url: urls.wikipedia,
              imageUrl: 'assets/images/wikipedia-light.png',
            ),
          if (urls.amazon.isNotEmpty)
            linkCircleButton(
              delay: 0.3,
              name: 'Amazon',
              url: urls.amazon,
              imageUrl: 'assets/images/amazon.png',
            ),
          if (urls.facebook.isNotEmpty)
            linkCircleButton(
              delay: 0.4,
              name: 'Facebook',
              url: urls.facebook,
              imageUrl: 'assets/images/facebook.png',
            ),
          if (urls.instagram.isNotEmpty)
            linkCircleButton(
              delay: 0.5,
              name: 'Instagram',
              url: urls.instagram,
              imageUrl: 'assets/images/instagram.png',
            ),
          if (urls.netflix.isNotEmpty)
            linkCircleButton(
              delay: 0.6,
              name: 'Netflix',
              url: urls.netflix,
              imageUrl: 'assets/images/netflix.png',
            ),
          if (urls.primeVideo.isNotEmpty)
            linkCircleButton(
              delay: 0.7,
              name: 'Prime Video',
              url: urls.primeVideo,
              imageUrl: 'assets/images/prime-video.png',
            ),
          if (urls.twitch.isNotEmpty)
            linkCircleButton(
              delay: 0.8,
              name: 'Twitch',
              url: urls.twitch,
              imageUrl: 'assets/images/twitch.png',
            ),
          if (urls.twitter.isNotEmpty)
            linkCircleButton(
              delay: 0.9,
              name: 'Twitter',
              url: urls.twitter,
              imageUrl: 'assets/images/twitter.png',
            ),
          if (urls.youtube.isNotEmpty)
            linkCircleButton(
              delay: 1.0,
              name: 'Youtube',
              url: urls.youtube,
              imageUrl: 'assets/images/youtube.png',
            ),
        ],
      ),
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

    final horPadding = MediaQuery.of(context).size.width < 400.0 ? 10.0 : 20.0;

    return Observer(
      builder: (context) {
        final isConnected = userState.isUserConnected;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final quote = quotes.elementAt(index);

              return Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 700.0,
                    ),
                    child: QuoteRowWithActions(
                      quote: quote,
                      quoteId: quote.id,
                      quoteFontSize: 18.0,
                      isConnected: isConnected,
                      color: stateColors.appBackground,
                      padding: EdgeInsets.symmetric(
                        horizontal: horPadding,
                        vertical: 10.0,
                      ),
                    ),
                  ),
                ],
              );
            },
            childCount: quotes.length,
          ),
        );
      },
    );
  }

  Widget authorPanel() {
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
              child: summaryContainer(),
            ),
        ],
      ),
    );
  }

  Widget summaryContainer() {
    final width = MediaQuery.of(context).size.width < 600.0 ? 600.0 : 800;

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
          width: width,
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
          OutlineButton.icon(
            onPressed: () => launch(author.urls.wikipedia),
            icon: Icon(Icons.open_in_new),
            label: Text('More on Wikipedia'),
          ),
      ],
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('authors')
          .doc(widget.id)
          .get();

      if (!docSnap.exists) {
        isLoading = false;
        return;
      }

      final data = docSnap.data();
      data['id'] = docSnap.id;

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
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('author.id', isEqualTo: widget.id)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        lastDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == limit;
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
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('author.id', isEqualTo: widget.id)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        isLoadingMore = false;
        lastDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == limit;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }
}
