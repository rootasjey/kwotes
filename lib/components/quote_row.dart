import 'package:figstyle/state/colors.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/author_page.dart';
import 'package:figstyle/screens/reference_page.dart';
import 'package:figstyle/screens/quote_page.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class QuoteRow extends StatefulWidget {
  /// Specify this only when componentType = ComponentType.Card.
  /// If true, author will be displayed on card.
  final bool showAuthor;
  final bool useSwipeActions;

  final Color color;

  final double cardSize;
  final double elevation;
  final double quoteFontSize;

  final EdgeInsets padding;

  final Function itemBuilder;
  final Function onSelected;

  final ItemComponentType componentType;

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

  /// A widget positioned before the main content (quote's content).
  /// Typcally an Icon or a small Container.
  final Widget leading;

  QuoteRow({
    this.cardSize = 250.0,
    this.color,
    this.elevation,
    this.quote,
    this.quoteId,
    this.itemBuilder,
    this.key,
    this.componentType = ItemComponentType.row,
    this.onSelected,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.quoteFontSize = 24.0,
    this.showAuthor = false,
    this.stackChildren = const [],
    this.leading,
    this.leadingActions = defaultActions,
    this.trailingActions = defaultActions,
    this.useSwipeActions = false,
  });

  @override
  _QuoteRowState createState() => _QuoteRowState();
}

class _QuoteRowState extends State<QuoteRow> {
  bool elevationSpecified = false;

  Color iconColor;
  Color iconHoverColor;

  double elevation = 0.0;

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

  Widget cardLayout() {
    return Container(
      width: widget.cardSize,
      height: widget.cardSize,
      child: Card(
        elevation: elevation,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onQuoteTap,
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? getHoverElevation() : getElevation();
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
                      widget.quote.name,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.itemBuilder != null)
                Positioned(
                  right: 0,
                  child: PopupMenuButton<String>(
                    icon: Opacity(
                      opacity: 0.6,
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
              if (widget.showAuthor)
                Positioned(
                  left: 40.0,
                  bottom: 10.0,
                  child: quoteAuthor(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget quoteAuthor() {
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
                    child: AuthorPage(
                      id: widget.quote.author.id,
                    ),
                  ),
                ),
              );
            },
          );
        }

        showCupertinoModalBottomSheet(
          context: context,
          builder: (context, scrollController) => AuthorPage(
            id: widget.quote.author.id,
            scrollController: scrollController,
          ),
        );
      },
      child: Opacity(
        opacity: 0.6,
        child: Text(
          widget.quote.author.name,
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
          builder: (context, scrollController) => ReferencePage(
            id: widget.quote.mainReference.id,
            scrollController: scrollController,
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
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? getHoverElevation() : getElevation();
              iconColor = isHover ? iconHoverColor : null;
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

  double getHoverElevation() {
    return elevationSpecified ? widget.elevation * 2.0 : 2.0;
  }

  double getElevation() {
    return elevationSpecified ? widget.elevation : 0.0;
  }

  Future onQuoteTap() {
    final quote = widget.quote;
    final id = quote.quoteId != null && quote.quoteId.isNotEmpty
        ? quote.quoteId
        : quote.id;

    if (MediaQuery.of(context).size.width > 600.0) {
      return showFlash(
        context: context,
        persistent: false,
        builder: (context, controller) {
          return Flash.dialog(
            controller: controller,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    }

    return showCupertinoModalBottomSheet(
      context: context,
      builder: (context, scrollController) => QuotePage(
        padding: const EdgeInsets.only(left: 10.0),
        quote: widget.quote,
        quoteId: id,
        scrollController: scrollController,
      ),
    );
  }
}
