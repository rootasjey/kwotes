import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/actions/references.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/reference_avatar.dart';
import 'package:figstyle/components/square_action.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/utils/app_logger.dart';
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
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/language.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferencePage extends StatefulWidget {
  final String referenceId;
  final String referenceName;
  final String referenceImageUrl;

  ReferencePage({
    @PathParam('referenceId') this.referenceId,
    this.referenceName,
    this.referenceImageUrl,
  });

  @override
  ReferencePageState createState() => ReferencePageState();
}

class ReferencePageState extends State<ReferencePage> {
  bool isLoading = false;
  bool isLoadingMore = false;
  bool descending = true;
  bool hasNext = true;
  bool isSummaryVisible = false;

  DocumentSnapshot lastFetchedDoc;

  final limit = 30;
  final double beginY = 20.0;
  final pageRoute = 'reference_page';
  final _pageScrollController = ScrollController();

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
          controller: _pageScrollController,
          slivers: <Widget>[
            DesktopAppBar(),
            heroSection(),
            textsPanels(),
            userActions(),
            langDropdown(),
            quotesListView(),
            SliverPadding(padding: const EdgeInsets.only(bottom: 200.0)),
          ],
        ),
      ),
    );
  }

  /// Reference's picture profile (avatar) and name.
  Widget heroSection() {
    String referenceName = widget.referenceName;
    String referenceImageUrl = widget.referenceImageUrl;

    if (referenceName == null || referenceName.isEmpty) {
      referenceName = reference?.name;
    }

    if (referenceImageUrl == null || referenceImageUrl.isEmpty) {
      referenceImageUrl = reference?.urls?.image;
    }

    referenceImageUrl = referenceImageUrl ?? '';
    referenceName = referenceName ?? '';

    return SliverPadding(
      padding: const EdgeInsets.only(top: 100.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              if (referenceImageUrl.isNotEmpty)
                Hero(
                  tag: widget.referenceId,
                  child: ReferenceAvatar(
                    imageUrl: referenceImageUrl,
                  ),
                ),
              if (referenceName.isNotEmpty)
                Hero(
                  tag: '${widget.referenceId}-name',
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          referenceName,
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

  /// Reference's job, links and summary.
  Widget textsPanels() {
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
            return Container(
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Column(
                children: <Widget>[
                  FadeInY(
                    beginY: beginY,
                    delay: 200.milliseconds,
                    child: types(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 45.0,
                    ),
                    child: links(),
                  ),
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
            delay: 0,
            name: 'Website',
            url: urls.website,
            imageUrl: 'assets/images/world-globe.png',
          ),
        if (urls.wikipedia.isNotEmpty)
          linkSquareButton(
            delay: 100,
            name: 'Wikipedia',
            url: urls.wikipedia,
            // icon: FaIcon(FontAwesomeIcons.wikipediaW),
            imageUrl: 'assets/images/wikipedia-light.png',
          ),
        if (urls.amazon.isNotEmpty)
          linkSquareButton(
            delay: 200,
            name: 'Amazon',
            url: urls.amazon,
            imageUrl: 'assets/images/amazon.png',
          ),
        if (urls.facebook.isNotEmpty)
          linkSquareButton(
            delay: 300,
            name: 'Facebook',
            url: urls.facebook,
            imageUrl: 'assets/images/facebook.png',
          ),
        if (urls.instagram.isNotEmpty)
          linkSquareButton(
            delay: 400,
            name: 'Instagram',
            url: urls.instagram,
            imageUrl: 'assets/images/instagram.png',
          ),
        if (urls.netflix.isNotEmpty)
          linkSquareButton(
            delay: 500,
            name: 'Netflix',
            url: urls.netflix,
            imageUrl: 'assets/images/netflix.png',
          ),
        if (urls.primeVideo.isNotEmpty)
          linkSquareButton(
            delay: 006,
            name: 'Prime Video',
            url: urls.primeVideo,
            imageUrl: 'assets/images/prime-video.png',
          ),
        if (urls.twitch.isNotEmpty)
          linkSquareButton(
            delay: 700,
            name: 'Twitch',
            url: urls.twitch,
            imageUrl: 'assets/images/twitch.png',
          ),
        if (urls.twitter.isNotEmpty)
          linkSquareButton(
            delay: 800,
            name: 'Twitter',
            url: urls.twitter,
            imageUrl: 'assets/images/twitter.png',
          ),
        if (urls.youtube.isNotEmpty)
          linkSquareButton(
            delay: 900,
            name: 'Youtube',
            url: urls.youtube,
            imageUrl: 'assets/images/youtube.png',
          ),
      ],
    );
  }

  Widget linkSquareButton({
    int delay = 0,
    String name,
    String url,
    String imageUrl,
    Widget icon,
  }) {
    return FadeInX(
      beginX: 10.0,
      delay: Duration(milliseconds: delay),
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
        titleString: "No quote found",
        descriptionString: "Sorry, we didn't found any quote "
            "in ${Language.frontend(lang)} for ${reference.name}. "
            "You can try in another language.",
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
        Divider(thickness: 1.0),
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
        Divider(
          height: 80.0,
          thickness: 1.0,
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

  Widget userActions() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([]),
      );
    }

    final buttonsList = <Widget>[
      SquareAction(
        icon: Icon(UniconsLine.share),
        borderColor: Colors.blue,
        tooltip: 'Share this reference',
        onTap: () async {
          ShareActions.shareReference(
            context: context,
            reference: reference,
          );
        },
      ),
    ];

    if (stateUser.canManageReferences) {
      buttonsList.addAll([
        SquareAction(
          icon: Icon(UniconsLine.trash),
          borderColor: Colors.pink,
          tooltip: "Delete reference",
          onTap: () => confirmAndDeleteReference(),
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
                    EditReferenceRoute(
                      referenceId: reference.id,
                      reference: reference,
                    ),
                  ],
                )
              ])
            ]),
          ),
        ),
      ]);
    }

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 40.0,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5.0,
            children: buttonsList,
          ),
        ),
      ]),
    );
  }

  void confirmAndDeleteReference() async {
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
              deleteReferenceAndNavBack();
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
                    onTap: deleteReferenceAndNavBack,
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

  void deleteReferenceAndNavBack() {
    context.router.pop();

    ReferencesActions.delete(
      reference: reference,
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
    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('references')
          .doc(widget.referenceId)
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
      appLogger.d(error);
      setState(() => isLoading = false);
    }
  }

  void fetchQuotes() async {
    quotes.clear();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('reference.id', isEqualTo: widget.referenceId)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => hasNext = false);
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
      appLogger.d(error);
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
          .where('reference.id', isEqualTo: widget.referenceId)
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
      appLogger.d(error);
      setState(() => isLoadingMore = false);
    }
  }
}
