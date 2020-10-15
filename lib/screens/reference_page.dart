import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/quote_row_with_actions.dart';
import 'package:memorare/components/sliver_empty_view.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/home_app_bar.dart';
import 'package:memorare/screens/quotes_by_author_ref.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/language.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferencePage extends StatefulWidget {
  final String id;
  final ScrollController scrollController;

  ReferencePage({this.id, this.scrollController});

  @override
  ReferencePageState createState() => ReferencePageState();
}

class ReferencePageState extends State<ReferencePage> {
  bool isLoading = false;
  bool isLoadingMore = false;
  bool descending = true;
  bool hasNext = true;
  bool isSummaryVisible = false;

  DocumentSnapshot lastDoc;

  double avatarInitHeight = 250.0;
  double avatarInitWidth = 200.0;

  double avatarHeight = 250.0;
  double avatarWidth = 200.0;

  final limit = 30;
  final double beginY = 20.0;
  final pageRoute = 'reference_page';

  List<Quote> quotes = [];

  Reference reference;
  TextOverflow nameEllipsis = TextOverflow.ellipsis;

  String lang = 'en';

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
    fetchQuotes();
  }

  void initProps() {
    lang = appLocalStorage.getPageLang(pageRoute: pageRoute);
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

          return false;
        },
        child: CustomScrollView(
          physics: ClampingScrollPhysics(),
          controller: widget.scrollController,
          slivers: <Widget>[
            HomeAppBar(
              title: reference != null ? reference.name : '',
              showCloseButton: true,
              showUserMenu: false,
            ),
            infoPanel(),
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
        ),
      ),
    );
  }

  Widget avatar({double scale = 1.0}) {
    final imageUrl = reference.urls.image;
    final imageUrlOk = imageUrl != null && imageUrl.length > 0;

    return AnimatedContainer(
      width: avatarWidth * scale,
      height: avatarHeight * scale,
      duration: 250.milliseconds,
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        elevation: imageUrlOk ? 5.0 : 0.0,
        child: imageUrlOk
            ? Ink.image(
                image: NetworkImage(
                  reference.urls.image,
                ),
                fit: BoxFit.contain,
                child: InkWell(
                  onHover: (isHover) {
                    if (isHover) {
                      setState(() {
                        avatarHeight = (avatarInitHeight) + 10.0;
                        avatarWidth = (avatarInitWidth) + 10.0;
                      });

                      return;
                    }

                    setState(() {
                      avatarHeight = avatarInitHeight;
                      avatarWidth = avatarInitWidth;
                    });

                    return;
                  },
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Container(
                              child: Image(
                                image: NetworkImage(reference.urls.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        });
                  },
                ),
              )
            : Center(
                child: Text(
                  reference.name.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    fontSize: 50.0,
                  ),
                ),
              ),
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

  Widget heroSmall() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FadeInY(
            beginY: beginY,
            delay: 1.0,
            child: avatar(),
          ),
          FadeInY(
            beginY: beginY,
            delay: 1.2,
            child: types(),
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

  Widget infoPanel() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: LoadingAnimation(
              textTitle: 'Loading reference...',
            ),
          ),
        ]),
      );
    }

    if (reference == null) {
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
                  child: avatar(scale: 1.5),
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
                  delay: 1.2,
                  child: types(),
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
                                  type: SubjectType.reference,
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
    final urls = reference.urls;

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
          delay: 0,
          child: Tooltip(
            message: "summary",
            child: SizedBox(
              height: 80.0,
              width: 80.0,
              child: Card(
                elevation: 4.0,
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
        ),
        if (urls.website.isNotEmpty)
          linkSquareButton(
            delay: 1.0,
            name: 'Website',
            url: urls.website,
            imageUrl: 'assets/images/world-globe.png',
          ),
        if (urls.wikipedia.isNotEmpty)
          Observer(
            builder: (_) {
              return linkSquareButton(
                delay: 1.2,
                name: 'Wikipedia',
                url: urls.wikipedia,
                imageUrl: 'assets/images/wikipedia-${stateColors.iconExt}.png',
              );
            },
          ),
        if (urls.amazon.isNotEmpty)
          linkSquareButton(
            delay: 1.2,
            name: 'Amazon',
            url: urls.amazon,
            imageUrl: 'assets/images/amazon.png',
          ),
        if (urls.facebook.isNotEmpty)
          linkSquareButton(
            delay: 1.4,
            name: 'Facebook',
            url: urls.facebook,
            imageUrl: 'assets/images/facebook.png',
          ),
        if (urls.instagram.isNotEmpty)
          linkSquareButton(
            delay: 1.7,
            name: 'Instagram',
            url: urls.instagram,
            imageUrl: 'assets/images/instagram.png',
          ),
        if (urls.netflix.isNotEmpty)
          linkSquareButton(
            delay: 1.6,
            name: 'Netflix',
            url: urls.netflix,
            imageUrl: 'assets/images/netflix.png',
          ),
        if (urls.primeVideo.isNotEmpty)
          linkSquareButton(
            delay: 1.8,
            name: 'Prime Video',
            url: urls.primeVideo,
            imageUrl: 'assets/images/prime-video.png',
          ),
        if (urls.twitch.isNotEmpty)
          linkSquareButton(
            delay: 2.0,
            name: 'Twitch',
            url: urls.twitch,
            imageUrl: 'assets/images/twitch.png',
          ),
        if (urls.twitter.isNotEmpty)
          linkSquareButton(
            delay: 2.2,
            name: 'Twitter',
            url: urls.twitter,
            imageUrl: 'assets/images/twitter.png',
          ),
        if (urls.youtube.isNotEmpty)
          linkSquareButton(
            delay: 2.4,
            name: 'Youtube',
            url: urls.youtube,
            imageUrl: 'assets/images/youtube.png',
          ),
      ],
    );
  }

  Widget linkSquareButton({
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
        child: SizedBox(
          height: 80.0,
          width: 80.0,
          child: Card(
            elevation: 4.0,
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
      ),
    );
  }

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: FlatButton(
        onPressed: () {
          setState(() {
            nameEllipsis = nameEllipsis == TextOverflow.ellipsis
                ? TextOverflow.visible
                : TextOverflow.ellipsis;
          });
        },
        child: Text(
          reference.name,
          textAlign: TextAlign.center,
          overflow: nameEllipsis,
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
            "Sorry, we didn't found any quote in ${Language.frontend(lang)} for ${reference.name}. You can try in another language.",
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
            reference.summary,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w100,
              height: 1.5,
            ),
          ),
        ),
        if (reference.urls.wikipedia?.isNotEmpty)
          OutlineButton(
            onPressed: () => launch(reference.urls.wikipedia),
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
                reference.summary,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w100,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (reference.urls.wikipedia?.isNotEmpty)
            OutlineButton(
              onPressed: () => launch(reference.urls.wikipedia),
              child: Text('More on Wikipedia'),
            )
        ],
      ),
    );
  }

  Widget types() {
    final type = reference.type;

    return Column(
      children: <Widget>[
        Opacity(
          opacity: 0.7,
          child: Text(
            type.primary,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
        if (type.secondary != null && type.secondary.length > 0)
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                type.secondary,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await Firestore.instance
          .collection('references')
          .document(widget.id)
          .get();

      if (!snapshot.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = snapshot.data;
      data['id'] = snapshot.documentID;

      setState(() {
        reference = Reference.fromJSON(data);

        nameEllipsis = reference.name.length > 42
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
          .where('mainReference.id', isEqualTo: widget.id)
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
          .where('mainReference.id', isEqualTo: widget.id)
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
