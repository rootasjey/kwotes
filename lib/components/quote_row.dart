import 'package:flutter/material.dart';
import 'package:figstyle/screens/author_page.dart';
import 'package:figstyle/screens/reference_page.dart';
import 'package:figstyle/screens/quote_page.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class QuoteRow extends StatefulWidget {
  final Quote quote;

  final double cardSize;
  final double elevation;

  final EdgeInsets padding;
  final Function itemBuilder;
  final Function onSelected;

  final ItemComponentType componentType;
  final List<Widget> stackChildren;

  /// Specify explicitly the quote'is
  /// because quote's id in favourites reflect
  /// the favourite's id and no the quote.
  final String quoteId;

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

  Widget cardLayout() {
    return Container(
      width: widget.cardSize,
      height: widget.cardSize,
      child: Card(
        elevation: elevation,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            showMaterialModalBottomSheet(
              context: context,
              builder: (context, scrollController) => QuotePage(
                quote: widget.quote,
                quoteId: widget.quote.id,
                scrollController: scrollController,
              ),
            );
          },
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? 2.0 : 0.0;
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
                      widget.quote.name.length > 60
                          ? '${widget.quote.name.substring(0, 60)}...'
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

  Widget quoteAuthor() {
    return InkWell(
      onTap: () {
        showMaterialModalBottomSheet(
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
        fontSize: 20.0,
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
        showMaterialModalBottomSheet(
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
    return Container(
      padding: widget.padding,
      child: Card(
        elevation: elevation,
        color: stateColors.appBackground,
        child: InkWell(
          onTap: () {
            showMaterialModalBottomSheet(
              context: context,
              builder: (context, scrollController) => QuotePage(
                quote: widget.quote,
                quoteId: widget.quote.id,
                scrollController: scrollController,
              ),
            );
          },
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? 2.0 : 0.0;
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
                      quoteName(),
                      Padding(padding: const EdgeInsets.only(top: 10.0)),
                      quoteAuthor(),
                      quoteReference(),
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
}
