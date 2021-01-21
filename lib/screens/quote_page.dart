import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/actions/quotes.dart';
import 'package:figstyle/actions/quotidians.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/user_lists.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/favourites.dart';
import 'package:figstyle/components/full_page_error.dart';
import 'package:figstyle/components/full_page_loading.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/components/topic_card_color.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/topic_color.dart';
import 'package:figstyle/utils/animation.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class QuotePage extends StatefulWidget {
  /// Quote object to show. If not available,
  /// the [quoteId] parameter can be specfied.
  final Quote quote;

  /// Quote's id to show. Cannot be null.
  final String quoteId;

  QuotePage({
    @PathParam('quoteId') this.quoteId,
    this.quote,
  });

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  /// True if data is loading.
  bool isLoading = false;

  /// If there is a previous page, will be false.
  bool showAnimations = false;

  Color accentColor = Colors.blue;

  final _pageScrollController = ScrollController();

  List<TopicColor> topicColors = [];

  Quote quote;

  @override
  void initState() {
    super.initState();

    if (widget.quote == null) {
      showAnimations = true;
      fetchQuote();
    } else {
      setState(() {
        showAnimations = false;
        quote = widget.quote;

        final topicColor = appTopicsColors.find(quote.topics.first);
        accentColor =
            topicColor != null ? Color(topicColor.decimal) : accentColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        controller: _pageScrollController,
        slivers: <Widget>[
          DesktopAppBar(),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              body(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget addToQuotidiansButton() {
    return IconButton(
      tooltip: "Add to quotidians",
      onPressed: () => addToQuotidians(
        quote: widget.quote,
        lang: widget.quote.lang,
      ),
      icon: Icon(Icons.wb_sunny),
    );
  }

  Widget addToListButton() {
    if (stateUser.isUserConnected) {
      return IconButton(
        tooltip: "Add to list...",
        onPressed: () => showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => UserLists(
            scrollController: ModalScrollController.of(context),
            quote: widget.quote,
          ),
        ),
        icon: Icon(Icons.playlist_add),
      );
    }

    return IconButton(
      tooltip: "You're not logged in",
      icon: Opacity(opacity: 0.5, child: Icon(Icons.playlist_add)),
      onPressed: () {
        showDialog(
            context: context,
            builder: (_) {
              return SimpleDialog(
                title: Text("You're not logged in"),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      "You must be logged in to add this quote to a list.",
                    ),
                  ),
                ],
              );
            });
      },
    );
  }

  Widget animatedDivider() {
    final topicColor = appTopicsColors.find(quote.topics.first);
    final color = topicColor != null ? Color(topicColor.decimal) : Colors.white;

    return CustomAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 200.0),
      child: Divider(
        color: color,
        thickness: 2.0,
      ),
      builder: (context, child, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: SizedBox(
            width: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget authorAndReference() {
    bool showBar = false;
    final author = quote?.author;
    final reference = quote?.mainReference;

    if (author != null &&
        author.name.isNotEmpty &&
        reference != null &&
        reference.name.isNotEmpty) {
      showBar = true;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          authorName(),
          if (showBar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('―'),
            ),
          referenceName(),
        ],
      ),
    );
  }

  Widget authorName() {
    return CustomAnimation(
      delay: 500.milliseconds,
      duration: 250.milliseconds,
      tween: Tween(begin: 0.0, end: 0.6),
      child: Tooltip(
        message: 'Author',
        child: InkWell(
          onTap: onTapAuthor,
          child: Text(
            quote.author.name,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      builder: (context, child, value) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
    );
  }

  Widget body() {
    if (isLoading) {
      return FullPageLoading(
        title: 'Loading quote...',
      );
    }

    if (quote == null) {
      return FullPageError(
        message: 'Error while loading the quote.',
      );
    }

    return pageLayout();
  }

  Widget deletePubQuoteButton() {
    return IconButton(
      tooltip: "Delete published quote",
      onPressed: () => confirmAndDeletePubQuote(),
      icon: Icon(Icons.delete_outline),
    );
  }

  Widget divider() {
    return FadeInY(
      beginY: 10.0,
      delay: 300.milliseconds,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
          bottom: 10.0,
        ),
        child: Container(
          width: 60.0,
          height: 5.0,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget favIconButton() {
    if (stateUser.isUserConnected) {
      return LikeButton(
        isLiked: quote.starred,
        likeBuilder: (bool isLiked) {
          return Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
          );
        },
        onTap: (bool isLiked) async {
          stateUser.mustUpdateFav = true;

          if (quote.starred) {
            final success = await unlikeQuote();
            return success ? !isLiked : null;
          }

          final success = await likeQuote();
          return success ? !isLiked : null;
        },
      );
    }

    return IconButton(
      tooltip: "You're not logged in",
      icon: Opacity(opacity: 0.5, child: Icon(Icons.favorite_border)),
      onPressed: () {
        showDialog(
            context: context,
            builder: (_) {
              return SimpleDialog(
                title: Text("You're not logged in"),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      "You must be logged in to like this quote.",
                    ),
                  ),
                ],
              );
            });
      },
    );
  }

  Widget desktopLayout() {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          userActions(),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                authorAndReference(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Card(
                      elevation: 2.0,
                      child: InkWell(
                        onTap: () {},
                        onLongPress: onLongPress,
                        child: Padding(
                          padding: const EdgeInsets.all(60.0),
                          child: createHeroQuoteAnimation(
                            quote: quote,
                            isMobile: size.width < 700.0,
                            screenWidth: size.width,
                            screenHeight: size.height,
                          ),
                        ),
                      ),
                    ),
                    topicsList(),
                  ],
                ),
                // topicsList(),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget mobileLayout() {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        children: [
          InkWell(
            onTap: () {},
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: createHeroQuoteAnimation(
                quote: quote,
                isMobile: size.width < 700.0,
                screenWidth: size.width,
                screenHeight: size.height,
              ),
            ),
          ),
          // authorAndReference(),
          authorName(),
          referenceName(),
          topicsList(),
          userActions(axis: Axis.horizontal),
        ],
      ),
    );
  }

  Widget pageLayout() {
    final size = MediaQuery.of(context).size;
    bool isWide = size.width >= Constants.maxMobileWidth;

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: desktopLayout(),
      );
      // return OrientationBuilder(
      //   builder: (context, orientation) {
      //     return Padding(
      //       padding: const EdgeInsets.only(top: 40.0),
      //       child: quoteName(),
      //     );
      //   },
      // );
    }

    return mobileLayout();
  }

  Widget referenceName() {
    if (quote.mainReference == null || quote.mainReference.name.isEmpty) {
      return Container();
    }

    return CustomAnimation(
      delay: 700.milliseconds,
      duration: 250.milliseconds,
      tween: Tween(begin: 0.0, end: 0.5),
      child: Tooltip(
        message: 'Reference',
        child: InkWell(
          onTap: onReferenceTap,
          child: Text(
            quote.mainReference.name,
            style: TextStyle(
              fontSize: 18.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
      builder: (context, child, value) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
    );
  }

  Widget shareButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        tooltip: 'Share this quote',
        onPressed: () async {
          shareQuote(context: context, quote: quote);
        },
        icon: Icon(Icons.share),
      ),
    );
  }

  Widget topicsList() {
    if (quote.topics.length == 0) {
      return Container();
    }

    final screenSize = MediaQuery.of(context).size;
    bool isNarrow = screenSize.width < Constants.maxMobileWidth;

    double cardSize = 50.0;
    EdgeInsets padding = EdgeInsets.zero;

    if (isNarrow) {
      cardSize = 70.0;
      padding = const EdgeInsets.only(top: 32.0);
    }

    return Padding(
      padding: padding,
      child: Wrap(
        alignment: WrapAlignment.end,
        children: quote.topics.map((topic) {
          final topicColor = appTopicsColors.find(topic);

          return TopicCardColor(
            elevation: 3.0,
            size: cardSize,
            color: Color(topicColor.decimal),
            tooltip: topicColor.name,
          );
        }).toList(),
      ),
    );
  }

  Widget userActions({Axis axis = Axis.vertical}) {
    var children = <Widget>[
      favIconButton(),
      shareButton(),
      addToListButton(),
    ];

    if (stateUser.canManageQuotes) {
      final ldivider = axis == Axis.horizontal
          ? VerticalDivider(thickness: 1.0)
          : Divider(
              thickness: 1.0,
              height: 26.0,
              indent: 12.0,
              endIndent: 12.0,
            );

      children.addAll([
        ldivider,
        addToQuotidiansButton(),
        deletePubQuoteButton(),
      ]);
    }

    if (axis == Axis.horizontal) {
      return Wrap(
        children: children,
      );
    }

    return Container(
      width: 80.0,
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: children,
      ),
    );
  }

  void confirmAndDeletePubQuote() async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                tileColor: Color(0xfff55c5c),
                onTap: () async {
                  context.router.pop();

                  final success = await deleteQuote(quote: widget.quote);

                  if (success) {
                    context.router.pop();
                  }
                },
              ),
              ListTile(
                title: Text('Cancel'),
                trailing: Icon(Icons.close),
                onTap: context.router.pop,
              ),
            ]),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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

  void fetchTopics() async {
    final _topicsColors = <TopicColor>[];

    for (String topicName in quote.topics) {
      final doc = await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicName)
          .get();

      if (doc.exists) {
        final topic = TopicColor.fromJSON(doc.data());
        _topicsColors.add(topic);
      }
    }

    setState(() {
      topicColors = _topicsColors;
    });
  }

  void fetchQuote() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('quotes')
          .doc(widget.quoteId)
          .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = doc.data();
      data['id'] = doc.id;
      quote = Quote.fromJSON(data);

      await fetchIsFav();

      setState(() {
        isLoading = false;
      });

      fetchTopics();
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      debugPrint(error);
    }
  }

  Future fetchIsFav() async {
    if (stateUser.isUserConnected) {
      final isFav = await isFavourite(
        quoteId: quote.id,
      );

      quote.starred = isFav;
    }
  }

  Future<bool> likeQuote() async {
    final success = await addToFavourites(
      context: context,
      quote: quote,
    );

    return success;
  }

  void onLongPress() {
    final children = [
      ListTile(
        title: Text('Share'),
        trailing: Icon(
          Icons.ios_share,
        ),
        onTap: () {
          context.router.pop();
          shareQuote(context: context, quote: widget.quote);
        },
      ),
    ];

    if (stateUser.isUserConnected) {
      children.addAll([
        ListTile(
          title: Text('Add to...'),
          trailing: Icon(
            Icons.playlist_add,
          ),
          onTap: () {
            context.router.pop();
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => UserLists(
                scrollController: ModalScrollController.of(context),
                quote: widget.quote,
              ),
            );
          },
        ),
        ListTile(
          title: quote.starred ? Text('Unlike') : Text('Like'),
          trailing: quote.starred
              ? Icon(Icons.favorite)
              : Icon(Icons.favorite_border),
          onTap: () async {
            context.router.pop();
            stateUser.mustUpdateFav = true;

            final newValue = !quote.starred;

            setState(() => quote.starred = newValue);

            bool success = true;

            if (quote.starred) {
              success = await unlikeQuote();
            } else {
              success = await likeQuote();
            }

            if (!success) {
              setState(() => quote.starred = !newValue);
            }
          },
        ),
      ]);
    }

    if (stateUser.canManageQuotes) {
      children.addAll([
        ListTile(
          title: Text('Delete'),
          trailing: Icon(
            Icons.delete_outline,
          ),
          onTap: () {
            context.router.pop();
            confirmAndDeletePubQuote();
          },
        ),
        ListTile(
          title: Text('Next quotidian'),
          trailing: Icon(Icons.wb_sunny),
          onTap: () {
            context.router.pop();
            addToQuotidians(
              quote: widget.quote,
              lang: widget.quote.lang,
            );
          },
        ),
      ]);
    }

    int flex =
        MediaQuery.of(context).size.width < Constants.maxMobileWidth ? 5 : 1;

    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Row(
            children: [
              Spacer(),
              Expanded(
                flex: flex,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  void onTapAuthor() {
    context.router.root.push(
      AuthorsDeepRoute(children: [
        AuthorPageRoute(
          authorId: quote.author.id,
          authorName: quote.author.name,
        ),
      ]),
    );
  }

  void onReferenceTap() {
    context.router.root.push(
      ReferencesDeepRoute(children: [
        ReferencePageRoute(
          referenceId: quote.mainReference.id,
          referenceName: quote.mainReference.name,
        )
      ]),
    );
  }

  Future<bool> unlikeQuote() async {
    final success = await removeFromFavourites(
      context: context,
      quote: quote,
    );

    return success;
  }
}
