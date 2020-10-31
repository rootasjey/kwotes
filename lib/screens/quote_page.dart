import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/favourites.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/add_to_list_button.dart';
import 'package:figstyle/components/full_page_error.dart';
import 'package:figstyle/components/full_page_loading.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/components/topic_card_color.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/screens/author_page.dart';
import 'package:figstyle/screens/reference_page.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/topic_color.dart';
import 'package:figstyle/utils/animation.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class QuotePage extends StatefulWidget {
  final bool pinnedAppBar;

  final EdgeInsets padding;

  final Quote quote;

  final ScrollController scrollController;
  final String quoteId;

  QuotePage({
    this.padding = EdgeInsets.zero,
    this.pinnedAppBar = true,
    this.quoteId,
    this.quote,
    this.scrollController,
  });

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  bool isLoading = false;

  Color accentColor = Colors.blue;

  List<TopicColor> topicColors = [];

  Quote quote;

  @override
  void initState() {
    super.initState();

    if (widget.quote == null) {
      fetchQuote();
    } else {
      setState(() {
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
        controller: widget.scrollController,
        slivers: <Widget>[
          DesktopAppBar(
            padding: widget.padding,
            pinned: widget.pinnedAppBar,
            showCloseButton: true,
            showUserMenu: false,
          ),
          SliverList(
              delegate: SliverChildListDelegate.fixed([
            body(),
          ])),
        ],
      ),
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

    return OrientationBuilder(
      builder: (context, orientation) {
        return Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: 100.0,
                left: 20.0,
                right: 20.0,
                bottom: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  quoteName(),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                            child: Column(children: [
                          authorName(),
                          if (quote.mainReference.name.length > 0)
                            referenceName(),
                        ])),
                        verticalAnimatedDivider(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            userActions(),
            topicsList(),
          ],
        );
      },
    );
  }

  Widget animatedDivider() {
    final topicColor = appTopicsColors.find(quote.topics.first);
    final color = topicColor != null ? Color(topicColor.decimal) : Colors.white;

    return ControlledAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 200.0),
      child: Divider(
        color: color,
        thickness: 2.0,
      ),
      builderWithChild: (context, child, value) {
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

  Widget verticalAnimatedDivider() {
    return ControlledAnimation(
      delay: 1.seconds,
      duration: 250.milliseconds,
      tween: Tween(begin: 0.0, end: 60.0),
      builder: (context, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 8.0),
          child: Container(
            width: 3.0,
            height: value,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
      },
    );
  }

  Widget authorName() {
    final fontSize = MediaQuery.of(context).size.width < 400.0 ? 18.0 : 25.0;

    return ControlledAnimation(
      delay: 1.seconds,
      duration: 250.milliseconds,
      tween: Tween(begin: 0.0, end: 0.6),
      child: InkWell(
        onTap: () {
          final id = quote.author.id;

          showCupertinoModalBottomSheet(
              context: context,
              builder: (_, scrollController) => AuthorPage(
                    id: id,
                    scrollController: scrollController,
                  ));
        },
        child: Text(
          quote.author.name,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
      ),
      builderWithChild: (context, child, value) {
        return Align(
          alignment: Alignment.topRight,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget quoteName() {
    final size = MediaQuery.of(context).size;

    return createHeroQuoteAnimation(
      quote: quote,
      isMobile: size.width < 700.0,
      screenWidth: size.width,
      screenHeight: size.height,
    );
  }

  Widget referenceName() {
    return ControlledAnimation(
      delay: 1.2.seconds,
      duration: 250.milliseconds,
      tween: Tween(begin: 0.0, end: 0.5),
      child: InkWell(
        onTap: () {
          final id = quote.mainReference.id;

          showCupertinoModalBottomSheet(
              context: context,
              builder: (_, scrollController) => ReferencePage(
                    id: id,
                    scrollController: scrollController,
                  ));
        },
        child: Text(
          quote.mainReference.name,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 18.0,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      builderWithChild: (context, child, value) {
        return Align(
          alignment: Alignment.topRight,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget topicsList() {
    if (quote.topics.length == 0) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Divider(
            thickness: 1.0,
          ),
          SizedBox(
            height: 300,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                top: 80.0,
              ),
              scrollDirection: Axis.horizontal,
              children: quote.topics.map((topic) {
                final topicColor = appTopicsColors.find(topic);

                return TopicCardColor(
                  elevation: 3.0,
                  color: Color(topicColor.decimal),
                  name: topicColor.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget userActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          favIconButton(),
          shareButton(),
          addToListButton(),
        ],
      ),
    );
  }

  void addQuoteToFav() async {
    setState(() {
      // Optimistic result
      quote.starred = true;
    });

    final result = await addToFavourites(
      context: context,
      quote: quote,
    );

    if (!result) {
      setState(() {
        quote.starred = false;
      });
    }
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
    if (userState.isUserConnected) {
      final isFav = await isFavourite(
        quoteId: quote.id,
      );

      quote.starred = isFav;
    }
  }

  void removeQuoteFromFav() async {
    setState(() {
      // Optimistic result
      quote.starred = false;
    });

    final result = await removeFromFavourites(
      context: context,
      quote: quote,
    );

    if (!result) {
      setState(() {
        quote.starred = true;
      });
    }
  }

  Widget favIconButton() {
    if (userState.isUserConnected) {
      return IconButton(
        onPressed: () async {
          if (quote.starred) {
            removeQuoteFromFav();
            return;
          }

          addQuoteToFav();
        },
        icon:
            quote.starred ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
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

  Widget shareButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: IconButton(
        onPressed: () async {
          shareQuote(context: context, quote: quote);
        },
        icon: Icon(Icons.share),
      ),
    );
  }

  Widget addToListButton() {
    if (userState.isUserConnected) {
      return AddToListButton(
        quote: quote,
        isDisabled: !userState.isUserConnected,
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
}
