import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/actions/authors.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/author_avatar.dart';
import 'package:figstyle/components/square_action.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/language.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorPage extends StatefulWidget {
  final String authorId;
  final String authorName;
  final String authorImageUrl;

  AuthorPage({
    @required @PathParam('authorId') this.authorId,
    this.authorImageUrl = '',
    this.authorName = '',
  });

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

  DocumentSnapshot lastFetchedDoc;

  double beginY = 20.0;

  final limit = 30;
  final pageRoute = 'author_page';

  List<Quote> quotes = [];

  String lang = 'en';

  final _pageScrollController = ScrollController();

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
            controller: _pageScrollController,
            slivers: <Widget>[
              DesktopAppBar(),
              heroSection(),
              textsPanels(),
              langDropdown(),
              quotesListView(),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 200.0),
              ),
            ],
          )),
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
      ),
    );
  }

  /// Author picture profile (avatar) and name.
  Widget heroSection() {
    String authorName = widget.authorName;
    String authorImageUrl = widget.authorImageUrl;

    if (authorName == null || authorName.isEmpty) {
      authorName = author?.name;
    }

    if (authorImageUrl == null || authorImageUrl.isEmpty) {
      authorImageUrl = author?.urls?.image;
    }

    authorImageUrl = authorImageUrl ?? '';
    authorName = authorName ?? '';

    Widget authorAvatar;

    if (authorImageUrl.isNotEmpty) {
      authorAvatar = Hero(
        tag: widget.authorId,
        child: AuthorAvatar(
          imageUrl: authorImageUrl,
        ),
      );
    } else {
      authorAvatar = Material(
        elevation: 2.0,
        clipBehavior: Clip.hardEdge,
        shape: CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Opacity(
            opacity: 0.6,
            child: Icon(UniconsLine.user, size: 54.0),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 100.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              authorAvatar,
              if (authorName.isNotEmpty)
                Hero(
                  tag: '${widget.authorId}-name',
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          authorName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ]),
      ),
    );
  }

  /// Author's job, links and summary.
  Widget textsPanels() {
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
            message: "There was an error while loading the author's data",
            onRefresh: () => fetch(),
          ),
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        LayoutBuilder(
          builder: (context, constrains) {
            return Container(
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                children: <Widget>[
                  FadeInY(
                    beginY: beginY,
                    delay: 200.milliseconds,
                    child: job(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 60.0,
                    ),
                    child: links(),
                  ),
                  userActions(),
                  if (isSummaryVisible)
                    FadeInY(
                      beginY: -20.0,
                      endY: 0.0,
                      child: summaryContainer(),
                    ),
                ],
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget linkCircleButton({
    int delay = 0,
    String name,
    String url,
    String imageUrl,
  }) {
    return FadeInX(
      beginX: 50.0,
      delay: Duration(milliseconds: delay),
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

  Widget job() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
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

  Widget langDropdown() {
    Widget child;

    if (isLoading) {
      child = Padding(
        padding: EdgeInsets.zero,
      );
    } else {
      child = Padding(
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

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 20.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Center(child: child),
        ]),
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
            delay: 0.seconds,
            child: Tooltip(
              message: isSummaryVisible ? "Hide summary" : "Show summary",
              child: Material(
                elevation: 4.0,
                shape: CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    setState(() => isSummaryVisible = !isSummaryVisible);

                    if (isSummaryVisible) {
                      Future.delayed(
                        250.milliseconds,
                        () => _pageScrollController.animateTo(
                          500.0,
                          duration: 250.milliseconds,
                          curve: Curves.bounceIn,
                        ),
                      );
                    }
                  },
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
              delay: 0,
              name: 'Website',
              url: urls.website,
              imageUrl: 'assets/images/world-globe.png',
            ),
          if (urls.wikipedia.isNotEmpty)
            linkCircleButton(
              delay: 100,
              name: 'Wikipedia',
              url: urls.wikipedia,
              imageUrl: 'assets/images/wikipedia-light.png',
            ),
          if (urls.amazon.isNotEmpty)
            linkCircleButton(
              delay: 200,
              name: 'Amazon',
              url: urls.amazon,
              imageUrl: 'assets/images/amazon.png',
            ),
          if (urls.facebook.isNotEmpty)
            linkCircleButton(
              delay: 300,
              name: 'Facebook',
              url: urls.facebook,
              imageUrl: 'assets/images/facebook.png',
            ),
          if (urls.instagram.isNotEmpty)
            linkCircleButton(
              delay: 400,
              name: 'Instagram',
              url: urls.instagram,
              imageUrl: 'assets/images/instagram.png',
            ),
          if (urls.netflix.isNotEmpty)
            linkCircleButton(
              delay: 500,
              name: 'Netflix',
              url: urls.netflix,
              imageUrl: 'assets/images/netflix.png',
            ),
          if (urls.primeVideo.isNotEmpty)
            linkCircleButton(
              delay: 600,
              name: 'Prime Video',
              url: urls.primeVideo,
              imageUrl: 'assets/images/prime-video.png',
            ),
          if (urls.twitch.isNotEmpty)
            linkCircleButton(
              delay: 700,
              name: 'Twitch',
              url: urls.twitch,
              imageUrl: 'assets/images/twitch.png',
            ),
          if (urls.twitter.isNotEmpty)
            linkCircleButton(
              delay: 800,
              name: 'Twitter',
              url: urls.twitter,
              imageUrl: 'assets/images/twitter.png',
            ),
          if (urls.youtube.isNotEmpty)
            linkCircleButton(
              delay: 900,
              name: 'Youtube',
              url: urls.youtube,
              imageUrl: 'assets/images/youtube.png',
            ),
        ],
      ),
    );
  }

  Widget quotesListView() {
    if (isLoading) {
      return SliverPadding(padding: EdgeInsets.zero);
    }

    if (quotes.isEmpty) {
      return SliverEmptyView(
        titleString: "No quote found",
        descriptionString: "Sorry, we didn't found any quote in"
            "${Language.frontend(lang)} for ${author?.name}."
            " You can try in another language.",
        onRefresh: () => fetchQuotes(),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final horPadding = width < 400.0 ? 10.0 : 20.0;

    return Observer(
      builder: (context) {
        final isConnected = stateUser.isUserConnected;

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
        Divider(
          height: 80.0,
          thickness: 1.0,
        ),
      ],
    );
  }

  Widget userActions() {
    final buttonsList = <Widget>[
      SquareAction(
        icon: Icon(UniconsLine.share),
        borderColor: Colors.blue,
        tooltip: 'Share this author',
        onTap: () async {
          ShareActions.shareAuthor(
            context: context,
            author: author,
          );
        },
      ),
    ];

    if (stateUser.canManageAuthors) {
      buttonsList.addAll([
        SquareAction(
          icon: Icon(UniconsLine.trash),
          borderColor: Colors.pink,
          tooltip: "Delete author",
          onTap: () => confirmAndDeleteAuthor(),
        ),
        SquareAction(
          icon: Icon(UniconsLine.edit),
          borderColor: Colors.amber,
          tooltip: "Edit author",
          onTap: () => context.router.root.push(
            DashboardPageRoute(children: [
              AdminDeepRoute(children: [
                AdminEditDeepRoute(
                  children: [
                    EditAuthorRoute(
                      authorId: author.id,
                      author: author,
                    ),
                  ],
                )
              ])
            ]),
          ),
        ),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Wrap(
        spacing: 5.0,
        children: buttonsList,
      ),
    );
  }

  void confirmAndDeleteAuthor() async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        final focusNode = FocusNode();

        return RawKeyboardListener(
          autofocus: true,
          focusNode: focusNode,
          onKey: (keyEvent) {
            if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter) ||
                keyEvent.isKeyPressed(LogicalKeyboardKey.space)) {
              deleteAuthorAndNavBack();
              return;
            }
          },
          child: Material(
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    tileColor: stateColors.deletion,
                    onTap: deleteAuthorAndNavBack,
                  ),
                  ListTile(
                    title: Text('Cancel'),
                    trailing: Icon(Icons.close),
                    onTap: context.router.pop,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(12.0),
              child: child,
            ),
          ),
        );
      },
    );
  }

  void deleteAuthorAndNavBack() {
    context.router.pop();

    AuthorsActions.delete(
      author: author,
    );

    if (context.router.root.stack.length > 1) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        context.router.pop();
      });
      return;
    }

    context.router.root.push(HomeRoute());
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('authors')
          .doc(widget.authorId)
          .get();

      if (!docSnap.exists) {
        isLoading = false;
        return;
      }

      final data = docSnap.data();
      data['id'] = docSnap.id;

      setState(() {
        author = Author.fromJSON(data);
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
          .where('author.id', isEqualTo: widget.authorId)
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
        lastFetchedDoc = snapshot.docs.last;
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
          .where('author.id', isEqualTo: widget.authorId)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastFetchedDoc)
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
        lastFetchedDoc = snapshot.docs.last;
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
