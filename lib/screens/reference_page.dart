import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/image_hero.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/components/sliver_empty_view.dart';
import 'package:figstyle/components/fade_in_x.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/language.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferencePage extends StatefulWidget {
  final String id;
  final ScrollController scrollController;

  ReferencePage({@required this.id, this.scrollController});

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
    lang = appStorage.getPageLang(pageRoute: pageRoute);
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
            DesktopAppBar(
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
    final isImageUrlOk = imageUrl != null && imageUrl.length > 0;

    return OpenContainer(
      closedColor: Colors.transparent,
      closedBuilder: (context, openContainer) {
        return AnimatedContainer(
          width: avatarWidth * scale,
          height: avatarHeight * scale,
          duration: 250.milliseconds,
          child: Ink.image(
            height: avatarHeight * scale,
            width: avatarWidth * scale,
            fit: BoxFit.cover,
            image: isImageUrlOk
                ? NetworkImage(
                    reference.urls.image,
                  )
                : AssetImage('assets/images/reference.png'),
            child: InkWell(
              onTap: openContainer,
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
            ),
          ),
        );
      },
      openBuilder: (context, callback) {
        return ImageHero(
          imageProvider: isImageUrlOk
              ? NetworkImage(
                  reference.urls.image,
                )
              : AssetImage('assets/images/reference.png'),
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
            return refPanel();
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
        Tooltip(
          message: 'summary',
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
        if (urls.website.isNotEmpty)
          linkSquareButton(
            delay: 0.0,
            name: 'Website',
            url: urls.website,
            imageUrl: 'assets/images/world-globe.png',
          ),
        if (urls.wikipedia.isNotEmpty)
          linkSquareButton(
            delay: 0.1,
            name: 'Wikipedia',
            url: urls.wikipedia,
            // icon: FaIcon(FontAwesomeIcons.wikipediaW),
            imageUrl: 'assets/images/wikipedia-light.png',
          ),
        if (urls.amazon.isNotEmpty)
          linkSquareButton(
            delay: 0.2,
            name: 'Amazon',
            url: urls.amazon,
            imageUrl: 'assets/images/amazon.png',
          ),
        if (urls.facebook.isNotEmpty)
          linkSquareButton(
            delay: 0.3,
            name: 'Facebook',
            url: urls.facebook,
            imageUrl: 'assets/images/facebook.png',
          ),
        if (urls.instagram.isNotEmpty)
          linkSquareButton(
            delay: 0.4,
            name: 'Instagram',
            url: urls.instagram,
            imageUrl: 'assets/images/instagram.png',
          ),
        if (urls.netflix.isNotEmpty)
          linkSquareButton(
            delay: 0.5,
            name: 'Netflix',
            url: urls.netflix,
            imageUrl: 'assets/images/netflix.png',
          ),
        if (urls.primeVideo.isNotEmpty)
          linkSquareButton(
            delay: 0.6,
            name: 'Prime Video',
            url: urls.primeVideo,
            imageUrl: 'assets/images/prime-video.png',
          ),
        if (urls.twitch.isNotEmpty)
          linkSquareButton(
            delay: 0.7,
            name: 'Twitch',
            url: urls.twitch,
            imageUrl: 'assets/images/twitch.png',
          ),
        if (urls.twitter.isNotEmpty)
          linkSquareButton(
            delay: 0.8,
            name: 'Twitter',
            url: urls.twitter,
            imageUrl: 'assets/images/twitter.png',
          ),
        if (urls.youtube.isNotEmpty)
          linkSquareButton(
            delay: 0.9,
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
    Widget icon,
  }) {
    return FadeInX(
      beginX: 10.0,
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
                child: icon != null
                    ? icon
                    : Image.asset(
                        imageUrl,
                        width: 30.0,
                        color: stateColors.foreground,
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

    final width = MediaQuery.of(context).size.width;
    final horPadding = width < 400.0 ? 10.0 : 20.0;

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
                      key: ObjectKey(index),
                      useSwipeActions: width < Constants.maxMobileWidth,
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

  Widget refPanel() {
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
          OutlineButton.icon(
            onPressed: () => launch(reference.urls.wikipedia),
            icon: Icon(Icons.open_in_new),
            label: Text('More on Wikipedia'),
          ),
      ],
    );
  }

  Widget types() {
    final type = reference.type;

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          Opacity(
            opacity: 0.8,
            child: Text(
              type.primary,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (type.secondary != null && type.secondary.length > 0)
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  type.secondary,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('references')
          .doc(widget.id)
          .get();

      if (!snapshot.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = snapshot.data();
      data['id'] = snapshot.id;

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
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('mainReference.id', isEqualTo: widget.id)
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
          .where('mainReference.id', isEqualTo: widget.id)
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
