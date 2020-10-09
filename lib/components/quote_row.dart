import 'package:flutter/material.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/web/add_to_list_button.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/enums.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/utils/animation.dart';
import 'package:stopper/stopper.dart';

class QuoteRow extends StatefulWidget {
  final Quote quote;

  /// Specify explicitly the quote'is
  /// because quote's id in favourites reflect
  /// the favourite's id and no the quote.
  final String quoteId;
  final Function itemBuilder;
  final Function onSelected;
  final EdgeInsets padding;
  final ItemComponentType componentType;
  final double cardSize;
  final double elevation;
  final List<Widget> stackChildren;

  /// A widget positioned before the main content (quote's content).
  /// Typcally an Icon or a small Container.
  final Widget leading;

  QuoteRow({
    this.cardSize = 250.0,
    this.elevation = 0.0,
    this.quote,
    this.quoteId,
    this.itemBuilder,
    this.componentType = ItemComponentType.row,
    this.onSelected,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.stackChildren = const [],
    this.leading,
  });

  @override
  _QuoteRowState createState() => _QuoteRowState();
}

class _QuoteRowState extends State<QuoteRow> {
  double elevation = 0.0;
  Color iconColor;
  Color iconHoverColor;

  @override
  initState() {
    super.initState();
    var topicColor = appTopicsColors.find(widget.quote.topics.first);

    if (topicColor == null) {
      topicColor = appTopicsColors.topicsColors.first;
    }

    setState(() {
      elevation = widget.elevation;
      iconHoverColor = Color(topicColor.decimal);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.componentType == ItemComponentType.row) {
      return rowLayout();
    }

    return cardLayout();
  }

  Widget addToListButton() {
    if (userState.isUserConnected) {
      return AddToListButton(
        quote: widget.quote,
      );
    }

    return IconButton(
      tooltip: 'You must login to add this quote to a list',
      icon: Opacity(
        opacity: 0.5,
        child: Icon(Icons.playlist_add),
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (_) {
              return SimpleDialog(
                title: Text("You're not logged in"),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                          "You must login to your account to add this quote to a list."),
                    ),
                  ),
                ],
              );
            });
      },
    );
  }

  Widget cardLayout() {
    return Container(
      width: widget.cardSize,
      height: widget.cardSize,
      child: Card(
        elevation: elevation,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => AuthorPage(id: widget.quote.author.id)),
            );
          },
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? widget.elevation * 2.0 : widget.elevation;
              iconColor = isHover ? iconHoverColor : null;
            });
          },
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.quote.name.length > 115
                          ? '${widget.quote.name.substring(0, 115)}...'
                          : widget.quote.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        // fontSize: FontSize.gridItem(widget.title),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.itemBuilder != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: PopupMenuButton<String>(
                    icon: Opacity(
                      opacity: .6,
                      child: iconColor != null
                          ? Icon(
                              Icons.more_vert,
                              color: iconColor,
                            )
                          : Icon(Icons.more_vert),
                    ),
                    onSelected: widget.onSelected,
                    itemBuilder: widget.itemBuilder,
                  ),
                ),
              if (widget.stackChildren.length > 0) ...widget.stackChildren,
            ],
          ),
        ),
      ),
    );
  }

  Widget likeButton() {
    final quote = widget.quote;

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
      tooltip: 'You must login to like this quote',
      icon: Opacity(opacity: 0.5, child: Icon(Icons.favorite_border)),
      onPressed: () {
        showDialog(
            context: context,
            builder: (_) {
              return SimpleDialog(
                title: Text("You're not logged in"),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                          "You must login to your account to like this quote."),
                    ),
                  ),
                ],
              );
            });
      },
    );
  }

  Widget rowLayout() {
    return Container(
      padding: widget.padding,
      child: Card(
        elevation: elevation,
        color: stateColors.appBackground,
        child: InkWell(
          onTap: () {
            showQuoteSheet();
          },
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? widget.elevation * 2.0 : widget.elevation;
              iconColor = isHover ? iconHoverColor : null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.leading != null) widget.leading,
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.quote.name,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(top: 10.0)),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    AuthorPage(id: widget.quote.author.id)),
                          );
                        },
                        child: Opacity(
                          opacity: .5,
                          child: Text(
                            widget.quote.author.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 50.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      PopupMenuButton<String>(
                        icon: Opacity(
                          opacity: .6,
                          child: iconColor != null
                              ? Icon(
                                  Icons.more_vert,
                                  color: iconColor,
                                )
                              : Icon(Icons.more_vert),
                        ),
                        onSelected: widget.onSelected,
                        itemBuilder: widget.itemBuilder,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sheetUserActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          likeButton(),
          shareButton(),
          addToListButton(),
        ],
      ),
    );
  }

  Widget shareButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: IconButton(
        onPressed: () async {
          shareQuote(context: context, quote: widget.quote);
        },
        icon: Icon(Icons.share),
      ),
    );
  }

  Widget topicsRow() {
    if (widget.quote.topics.length == 0) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 300,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                top: 80.0,
              ),
              scrollDirection: Axis.horizontal,
              children: widget.quote.topics.map((topic) {
                final topicColor = appTopicsColors.find(topic);

                return TopicCardColor(
                  color: Color(topicColor.decimal),
                  name: topicColor.name,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void addQuoteToFav() async {
    final quote = widget.quote;
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

  void removeQuoteFromFav() async {
    final quote = widget.quote;
    setState(() {
      // Optimistic result
      quote.starred = false;
    });

    final result = await removeFromFavourites(
      context: context,
      quote: widget.quote,
    );

    if (!result) {
      setState(() {
        quote.starred = true;
      });
    }
  }

  void showQuoteSheet() {
    final quote = widget.quote;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    showStopper(
      context: context,
      stops: [0.5 * height, height],
      builder: (context, scrollController, scrollPhysics, stop) {
        return Material(
          elevation: 4.0,
          child: ListView(
            controller: scrollController,
            physics: scrollPhysics,
            children: [
              Divider(
                thickness: 2.0,
              ),
              Center(
                child: Container(
                  height: 10.0,
                  width: 40.0,
                  padding: const EdgeInsets.only(top: 5.0),
                  decoration: BoxDecoration(
                    color: iconHoverColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: createHeroQuoteAnimation(
                  isMobile: true,
                  quote: quote,
                  screenWidth: width,
                  screenHeight: height,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Opacity(
                        opacity: 0.8,
                        child: Text(
                          quote.author.name,
                          style: TextStyle(fontSize: 20.0),
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Opacity(
                        opacity: 0.6,
                        child: Text(
                          quote.mainReference.name,
                          style: TextStyle(fontSize: 16.0),
                        )),
                  ],
                ),
              ),
              sheetUserActions(),
              topicsRow(),
            ],
          ),
        );
      },
    );
  }
}
