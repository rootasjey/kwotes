import 'package:flutter/material.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/temp_quote.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class TempQuoteRow extends StatefulWidget {
  final bool isDraft;

  /// If true, this will activate swipe actions
  /// and deactivate popup menu button.
  final bool useSwipeActions;

  final double cardSize;
  final double elevation;

  final EdgeInsets padding;

  final Function itemBuilder;
  final Function onLongPress;
  final Function onSelected;
  final Function onTap;

  final ItemComponentType componentType;

  /// Required if `useSwipeActions` is true.
  final Key key;

  final List<Widget> stackChildren;

  /// Swipe trailing actions.
  final List<SwipeAction> trailingActions;

  /// Swipe leadling actions.
  final List<SwipeAction> leadingActions;

  final TempQuote tempQuote;

  TempQuoteRow({
    this.cardSize = 250.0,
    this.elevation = 0.0,
    @required this.tempQuote,
    this.itemBuilder,
    this.isDraft = false,
    this.componentType = ItemComponentType.row,
    this.onSelected,
    this.onLongPress,
    this.onTap,
    this.stackChildren = const [],
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.useSwipeActions = false,
    this.key,
    this.trailingActions,
    this.leadingActions,
  });

  @override
  _TempQuoteRowState createState() => _TempQuoteRowState();
}

class _TempQuoteRowState extends State<TempQuoteRow> {
  bool elevationSpecified = false;

  Color iconColor;
  Color iconHoverColor;

  double elevation = 0.0;

  @override
  initState() {
    super.initState();
    final topics = widget.tempQuote.topics;
    Color color = stateColors.foreground;

    if (topics != null && topics.length > 0) {
      final topicColor = appTopicsColors.find(widget.tempQuote.topics.first);
      color = Color(topicColor.decimal);
    }

    setState(() {
      iconHoverColor = color;
      elevation = widget.elevation ?? 0.0;
      elevationSpecified = widget.elevation != null;
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
    final tempQuote = widget.tempQuote;

    return Container(
      width: widget.cardSize,
      height: widget.cardSize,
      child: Card(
        elevation: elevation,
        margin: EdgeInsets.zero,
        child: InkWell(
          onLongPress: widget.onLongPress,
          onTap: widget.onTap,
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? getHoverElevation() : getElevation();
              iconColor = isHover ? iconHoverColor : null;
            });
          },
          child: Stack(
            children: <Widget>[
              Padding(
                padding: widget.padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      tempQuote.name,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
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
                              Icons.more_horiz,
                              color: iconColor,
                            )
                          : Icon(Icons.more_horiz),
                    ),
                    onSelected: widget.onSelected,
                    itemBuilder: widget.itemBuilder,
                  ),
                ),
              if (widget.stackChildren.length > 0) ...widget.stackChildren,
              if (widget.isDraft)
                Positioned(
                  right: 0.0,
                  top: 15.0,
                  child: chipDraftInfo(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget chipDraftInfo() {
    final tempQuote = widget.tempQuote;

    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: Tooltip(
        message: tempQuote.isOffline ? 'Saved only locally' : 'Saved online',
        child: ClipOval(
          child: Material(
            color: tempQuote.isOffline ? Colors.red : Colors.green,
            child: InkWell(
              child: SizedBox(
                width: 15,
                height: 15,
              ),
              onTap: () {
                final text = tempQuote.isOffline
                    ? "This quote is saved in your device's offline storage. You can save it in the cloud after an edit to prevent data loss."
                    : "This quote is saved in the cloud so you can edit it on any other device.";

                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      return AlertDialog(
                        title: Row(
                          children: <Widget>[
                            Icon(
                              Icons.info,
                              color: Colors.blue,
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                              right: 15.0,
                            )),
                            Text('Information'),
                          ],
                        ),
                        content: Container(
                          width: 300.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Divider(
                                thickness: 1.0,
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                top: 15.0,
                              )),
                              Text(
                                text,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget rowLayout() {
    final quote = widget.tempQuote;
    final author = quote.author;

    final childRow = Container(
      padding: widget.padding,
      child: Card(
        elevation: elevation,
        color: stateColors.appBackground,
        child: InkWell(
          onLongPress: widget.onLongPress,
          onTap: widget.onTap,
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? getHoverElevation() : getElevation();
              iconColor = isHover ? iconHoverColor : null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            quote.name,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          Padding(padding: const EdgeInsets.only(top: 10.0)),
                          Opacity(
                            opacity: .5,
                            child: Text(
                              author == null || author.name.isEmpty
                                  ? ''
                                  : author.name,
                            ),
                          ),
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
                if (widget.isDraft)
                  Positioned(
                    right: 2.5,
                    child: chipDraftInfo(),
                  ),
              ],
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
}
