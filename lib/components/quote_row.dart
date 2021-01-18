import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/reference_page.dart';
import 'package:figstyle/screens/quote_page.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:mobx/mobx.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';

class QuoteRow extends StatefulWidget {
  /// Specify this only when componentType = ComponentType.Card.
  /// If true, author will be displayed on card.
  final bool showAuthor;

  /// If true, this card will have a border of 2.0px
  /// of the quote's first topic color.
  /// Available only when [componentType] = [ItemComponentType.verticalCard].
  final bool showBorder;

  /// If true, this will activate swipe actions
  /// and deactivate popup menu button.
  final bool useSwipeActions;

  final Color color;

  final double cardWidth;
  final double cardHeight;
  final double elevation;
  final double quoteFontSize;

  final EdgeInsets padding;

  final Function fetchIsFav;
  final Function itemBuilder;
  final Function onLongPress;
  final Function onSelected;

  final ItemComponentType componentType;

  final int maxLines;

  /// Required if `useSwipeActions` is true.
  final Key key;

  /// Widget to display on card item.
  final List<Widget> stackChildren;

  /// Swipe trailing actions.
  final List<SwipeAction> trailingActions;

  /// Swipe leadling actions.
  final List<SwipeAction> leadingActions;

  final Quote quote;

  /// Specify explicitly the quote'is
  /// because quote's id in favourites reflect
  /// the favourite's id and no the quote.
  final String quoteId;

  final TextOverflow overflow;

  /// A widget positioned before the main content (quote's content).
  /// Typcally an Icon or a small Container.
  final Widget leading;

  QuoteRow({
    this.cardWidth,
    this.cardHeight,
    this.color,
    this.componentType = ItemComponentType.row,
    this.elevation,
    this.fetchIsFav,
    this.itemBuilder,
    this.key,
    this.leading,
    this.leadingActions = defaultActions,
    this.maxLines = 6,
    this.onLongPress,
    this.onSelected,
    this.overflow = TextOverflow.ellipsis,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.quote,
    this.quoteId,
    this.quoteFontSize = 24.0,
    this.showAuthor = false,
    this.showBorder = false,
    this.stackChildren = const [],
    this.trailingActions = defaultActions,
    this.useSwipeActions = false,
  });

  @override
  _QuoteRowState createState() => _QuoteRowState();
}

class _QuoteRowState extends State<QuoteRow> with TickerProviderStateMixin {
  Animation<double> scaleAnimation;
  AnimationController scaleAnimationController;

  bool elevationSpecified = false;

  Color _cardBackgroundColor;
  Color _imageBackgroundColor;
  Color _accentColor;
  Color _iconColor;
  Color _textColor = Colors.white;

  double elevation = 0.0;

  ReactionDisposer textColorDisposer;

  String bgCardDefaultUrl = 'assets/images/ia_portrait.jpg';
  String bgCardImageUrl = '';

  @override
  initState() {
    super.initState();
    var topicColor = appTopicsColors.find(widget.quote.topics.first);

    if (topicColor == null) {
      topicColor = appTopicsColors.topicsColors.first;
    }

    setState(() {
      elevation = widget.elevation ?? 0.0;
      elevationSpecified = widget.elevation != null;
      _accentColor = Color(topicColor.decimal);
      _iconColor = _accentColor;
      _imageBackgroundColor = Colors.black45;
      _textColor = stateColors.foreground;
    });

    textColorDisposer = reaction(
      (_) => stateColors.foreground,
      (Color color) => _textColor = color,
    );

    if (widget.componentType == ItemComponentType.verticalCard) {
      fetchImageBackground();
    }

    if (widget.componentType == ItemComponentType.verticalCard ||
        widget.componentType == ItemComponentType.card) {
      scaleAnimationController = AnimationController(
        lowerBound: 0.8,
        upperBound: 1.0,
        duration: 500.milliseconds,
        vsync: this,
      );

      scaleAnimation = CurvedAnimation(
        parent: scaleAnimationController,
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void dispose() {
    if (widget.componentType == ItemComponentType.verticalCard ||
        widget.componentType == ItemComponentType.card) {
      scaleAnimationController?.dispose();
    }

    textColorDisposer?.reaction?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.componentType == ItemComponentType.row) {
      return rowLayout();
    }

    if (widget.componentType == ItemComponentType.verticalCard) {
      return verticalCardLayout();
    }

    return cardLayout();
  }

  Widget backgroundCardImage() {
    Widget imageWidget = Image.asset(
      bgCardDefaultUrl,
      fit: BoxFit.cover,
      width: widget.cardWidth,
      height: widget.cardHeight,
    );

    if (bgCardImageUrl != null && bgCardImageUrl.isNotEmpty) {
      imageWidget = Image.network(
        bgCardImageUrl,
        fit: BoxFit.cover,
        width: widget.cardWidth,
        height: widget.cardHeight,
      );
    }

    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: imageWidget,
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.4,
            child: Container(
              color: _imageBackgroundColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget cardLayout() {
    return Container(
      width: widget.cardWidth,
      height: widget.cardHeight,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Card(
          elevation: elevation,
          margin: EdgeInsets.zero,
          color: _cardBackgroundColor,
          shape: widget.showBorder
              ? Border(bottom: BorderSide(color: _accentColor, width: 2.0))
              : Border(),
          child: InkWell(
            onTap: onQuoteTap,
            onLongPress: widget.onLongPress,
            onHover: (isHover) {
              if (isHover) {
                scaleAnimationController.forward();
              } else {
                scaleAnimationController.reverse();
              }

              setState(() {
                elevation = isHover ? getHoverElevation() : getElevation();
                _cardBackgroundColor = isHover ? _accentColor : null;
                _iconColor = isHover ? Colors.white : _accentColor;
                _textColor = isHover ? Colors.white : stateColors.foreground;
              });
            },
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: widget.padding,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.quote.name,
                      maxLines: widget.maxLines,
                      overflow: widget.overflow,
                      style: TextStyle(
                        fontSize: widget.quoteFontSize,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                  ),
                ),
                if (widget.itemBuilder != null)
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: PopupMenuButton<String>(
                      icon: Opacity(
                        opacity: 0.6,
                        child: Icon(
                          Icons.more_vert,
                          color: _iconColor,
                        ),
                      ),
                      onSelected: widget.onSelected,
                      itemBuilder: widget.itemBuilder,
                    ),
                  ),
                if (widget.stackChildren.length > 0) ...widget.stackChildren,
                if (widget.showAuthor)
                  Positioned(
                    left: 0.0,
                    bottom: 15.0,
                    child: Padding(
                      padding: widget.padding != null
                          ? EdgeInsets.only(
                              left: widget.padding.left,
                              right: widget.padding.right,
                            )
                          : EdgeInsets.zero,
                      child: quoteAuthor(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget quoteAuthor() {
    return InkWell(
      onTap: () {
        final author = widget.quote.author;

        AuthorPageRoute(
          authorId: author.id,
          authorName: author.name,
        ).show(context);
      },
      child: Opacity(
        opacity: 0.6,
        child: Text(
          widget.quote.author.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _textColor,
          ),
        ),
      ),
    );
  }

  Widget quoteName() {
    return Text(
      widget.quote.name,
      style: TextStyle(
        fontSize: widget.quoteFontSize,
      ),
    );
  }

  Widget quoteReference() {
    final mainReference = widget.quote.mainReference;
    if (mainReference == null ||
        mainReference.id == null ||
        mainReference.id.isEmpty) {
      return Padding(padding: EdgeInsets.zero);
    }

    return InkWell(
      onTap: () {
        if (MediaQuery.of(context).size.width > 600.0) {
          return showFlash(
            context: context,
            persistent: false,
            builder: (context, controller) {
              return Flash.dialog(
                controller: controller,
                backgroundColor: stateColors.appBackground.withOpacity(1.0),
                enableDrag: true,
                margin: const EdgeInsets.only(
                  left: 120.0,
                  right: 120.0,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8.0),
                ),
                child: FlashBar(
                  message: Container(
                    height: MediaQuery.of(context).size.height - 100.0,
                    padding: const EdgeInsets.all(60.0),
                    child: ReferencePage(
                      id: widget.quote.mainReference.id,
                    ),
                  ),
                ),
              );
            },
          );
        }

        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => ReferencePage(
            id: widget.quote.mainReference.id,
            scrollController: ModalScrollController.of(context),
          ),
        );
      },
      child: Opacity(
        opacity: 0.4,
        child: Text(
          widget.quote.mainReference.name,
        ),
      ),
    );
  }

  Widget rowLayout() {
    final childRow = Container(
      padding: widget.padding,
      child: Card(
        elevation: elevation,
        color: widget.color,
        child: InkWell(
          onTap: onQuoteTap,
          onLongPress: widget.onLongPress,
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? getHoverElevation() : getElevation();
              _cardBackgroundColor = isHover ? _accentColor : null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (widget.leading != null) widget.leading,
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        quoteName(),
                        Padding(padding: const EdgeInsets.only(top: 10.0)),
                        quoteAuthor(),
                        quoteReference(),
                      ],
                    ),
                  ),
                  if (widget.itemBuilder != null)
                    SizedBox(
                      width: 50.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          PopupMenuButton<String>(
                            icon: Opacity(
                              opacity: 0.6,
                              child: _cardBackgroundColor != null
                                  ? Icon(
                                      Icons.more_vert,
                                      color: _cardBackgroundColor,
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
      ),
    );

    if (!widget.useSwipeActions) {
      return childRow;
    }

    return SwipeActionCell(
      key: widget.key,
      performsFirstActionWithFullSwipe: true,
      child: childRow,
      trailingActions: widget.trailingActions,
      leadingActions: widget.leadingActions,
    );
  }

  Widget verticalCardLayout() {
    return Container(
      width: widget.cardWidth,
      height: widget.cardHeight,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Card(
          elevation: elevation,
          margin: EdgeInsets.zero,
          shape: widget.showBorder
              ? Border(bottom: BorderSide(color: _accentColor, width: 2.0))
              : Border(),
          child: InkWell(
            onTap: onQuoteTap,
            onLongPress: widget.onLongPress,
            onHover: (isHover) {
              if (isHover) {
                scaleAnimationController.forward();
              } else {
                scaleAnimationController.reverse();
              }

              setState(() {
                elevation = isHover ? getHoverElevation() : getElevation();
                _cardBackgroundColor = isHover ? _accentColor : null;
                _imageBackgroundColor = isHover ? _accentColor : Colors.black45;
              });
            },
            child: Stack(
              children: <Widget>[
                backgroundCardImage(),
                Padding(
                  padding: widget.padding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.quote.name,
                        maxLines: widget.maxLines,
                        overflow: widget.overflow,
                        style: TextStyle(
                          fontSize: widget.quoteFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.itemBuilder != null)
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: PopupMenuButton<String>(
                      icon: Opacity(
                        opacity: 0.6,
                        child: Icon(
                          Icons.more_vert,
                          color: _textColor,
                        ),
                      ),
                      onSelected: widget.onSelected,
                      itemBuilder: widget.itemBuilder,
                    ),
                  ),
                if (widget.stackChildren.length > 0) ...widget.stackChildren,
                if (widget.showAuthor)
                  Positioned(
                    left: 40.0,
                    bottom: 16.0,
                    child: quoteAuthor(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double getHoverElevation() {
    return elevationSpecified ? widget.elevation * 2.0 : 2.0;
  }

  double getElevation() {
    return elevationSpecified ? widget.elevation : 0.0;
  }

  Future onQuoteTap() async {
    final quote = widget.quote;
    final id = quote.quoteId != null && quote.quoteId.isNotEmpty
        ? quote.quoteId
        : quote.id;

    final size = MediaQuery.of(context).size;

    if (size.width > Constants.maxMobileWidth &&
        size.height > Constants.maxMobileWidth) {
      await showFlash(
        context: context,
        persistent: false,
        builder: (context, controller) {
          return Flash.dialog(
            controller: controller,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            enableDrag: true,
            margin: const EdgeInsets.symmetric(
              horizontal: 120.0,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
            child: FlashBar(
              message: Container(
                height: MediaQuery.of(context).size.height - 100.0,
                padding: const EdgeInsets.all(60.0),
                child: QuotePage(
                  pinnedAppBar: false,
                  quote: widget.quote,
                  quoteId: id,
                ),
              ),
            ),
          );
        },
      );
    } else {
      await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => QuotePage(
          padding: const EdgeInsets.only(left: 10.0),
          quote: widget.quote,
          quoteId: id,
          scrollController: ModalScrollController.of(context),
        ),
      );
    }

    if (stateUser.mustUpdateFav) {
      stateUser.mustUpdateFav = false;

      if (widget.fetchIsFav != null) {
        widget.fetchIsFav();
      }
    }
  }

  void fetchImageBackground() async {
    String urlResult = await fetchAuthorPP();

    if (urlResult == null || urlResult.isEmpty) {
      urlResult = await fetchReferencePP();
    }

    setState(() => bgCardImageUrl = urlResult);
  }

  Future<String> fetchAuthorPP() async {
    try {
      final authorId = widget.quote.author.id;

      final authorDoc = await FirebaseFirestore.instance
          .collection('authors')
          .doc(authorId)
          .get();

      if (!authorDoc.exists) {
        return null;
      }

      final authorData = authorDoc.data();
      final author = Author.fromJSON(authorData);
      return author.urls.image;
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }

  Future<String> fetchReferencePP() async {
    try {
      final referenceId = widget.quote.mainReference.id;

      final referenceDoc = await FirebaseFirestore.instance
          .collection('references')
          .doc(referenceId)
          .get();

      if (!referenceDoc.exists) {
        return null;
      }

      final referenceData = referenceDoc.data();
      final reference = Reference.fromJSON(referenceData);
      return reference.urls.image;
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }
}
