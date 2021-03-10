import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/types/quotidian.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class QuotidianRow extends StatefulWidget {
  final bool useSwipeActions;

  final double cardSize;
  final double elevation;

  final EdgeInsets padding;

  final ItemComponentType componentType;

  final Key key;

  final Quotidian quotidian;

  final Function() onBeforeDelete;
  final Function(bool) onAfterDelete;

  QuotidianRow({
    this.cardSize = 250.0,
    this.componentType = ItemComponentType.row,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.quotidian,
    this.useSwipeActions = false,
    this.key,
    this.onBeforeDelete,
    this.onAfterDelete,
    this.elevation = 0.0,
  });

  @override
  _QuotidianRowState createState() => _QuotidianRowState();
}

class _QuotidianRowState extends State<QuotidianRow> {
  bool elevationSpecified = false;

  Color iconColor;
  Color iconHoverColor;

  double elevation = 0.0;

  @override
  initState() {
    super.initState();
    final topicColor =
        appTopicsColors.find(widget.quotidian.quote.topics.first);

    if (topicColor == null) {
      debugPrint("""Invalid topic for quote ${widget.quotidian.quote.id},
        topic: ${widget.quotidian.quote.topics.first}""");
    }

    setState(() {
      elevation = widget.elevation ?? 0.0;
      elevationSpecified = widget.elevation != null;
      iconHoverColor = topicColor?.decimal != null
          ? Color(topicColor.decimal)
          : stateColors.primary;
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
    final quote = widget.quotidian.quote;

    List<PopupMenuEntry<String>> popupItems = getPopupItems();
    Function itemBuilder = (BuildContext context) => popupItems;

    return SizedBox(
      width: widget.cardSize,
      height: widget.cardSize,
      child: Card(
        elevation: elevation,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => onTap(quote.id),
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? getHoverElevation() : getElevation();
              iconColor = isHover ? iconHoverColor : null;
            });
          },
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      quote.name.length > 60
                          ? '${quote.name.substring(0, 60)}...'
                          : quote.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (itemBuilder != null)
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
                    onSelected: onSelected,
                    itemBuilder: itemBuilder,
                  ),
                ),
              Positioned(
                right: 40.0,
                bottom: 5.0,
                child: Tooltip(
                  message: 'This quote will be shown on the ${getDate()}',
                  child: Material(
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    elevation: 0.0,
                    child: Ink(
                      child: InkWell(
                        onTap: () {},
                        child: CircleAvatar(
                          child: Text(
                            widget.quotidian.date.day.toString(),
                            style: TextStyle(
                              color: iconHoverColor,
                            ),
                          ),
                          backgroundColor: Colors.black12,
                          radius: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget rowLayout() {
    final quote = widget.quotidian.quote;

    List<PopupMenuEntry<String>> popupItems;
    Function itemBuilder;

    List<SwipeAction> trailingActions;

    if (widget.useSwipeActions) {
      trailingActions = getTrailingActions();
    } else {
      popupItems = getPopupItems();
      itemBuilder = (BuildContext context) => popupItems;
    }

    final childRow = Container(
      padding: widget.padding,
      child: Card(
        elevation: elevation,
        color: stateColors.appBackground,
        child: InkWell(
          onTap: () => onTap(quote.id),
          onHover: (isHover) {
            elevation = isHover ? 2.0 : 0.0;
            iconColor = isHover ? iconHoverColor : null;
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
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
                          fontSize: 20.0,
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(top: 10.0)),
                      GestureDetector(
                        onTap: () {
                          final author = quote.author;

                          AuthorPageRoute(
                            authorId: author.id,
                            authorName: author.name,
                          ).show(context);
                        },
                        child: Opacity(
                          opacity: .5,
                          child: Text(
                            quote.author.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (itemBuilder != null)
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
                          onSelected: onSelected,
                          itemBuilder: itemBuilder,
                        ),
                      ],
                    ),
                  ),
                Tooltip(
                  message: 'This quote will be shown on the ${getDate()}',
                  child: Material(
                    shape: CircleBorder(
                      side: BorderSide(
                        color: iconHoverColor,
                        width: 2.0,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    elevation: elevation,
                    child: Ink(
                      child: InkWell(
                        onTap: () {},
                        child: CircleAvatar(
                          child: Text(
                            widget.quotidian.date.day.toString(),
                          ),
                          foregroundColor: stateColors.foreground,
                          backgroundColor: Colors.black12,
                          radius: 20.0,
                        ),
                      ),
                    ),
                  ),
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
      trailingActions: trailingActions,
    );
  }

  List<SwipeAction> getTrailingActions() {
    final actions = <SwipeAction>[];

    actions.addAll([
      SwipeAction(
        title: 'Delete',
        icon: Icon(Icons.edit, color: Colors.white),
        color: stateColors.deletion,
        onTap: (CompletionHandler handler) {
          handler(false);
          deleteAction(widget.quotidian);
        },
      ),
    ]);
    return actions;
  }

  List<PopupMenuEntry<String>> getPopupItems() {
    return <PopupMenuEntry<String>>[
      PopupMenuItem(
        value: 'delete',
        child: ListTile(
          leading: Icon(Icons.delete),
          title: Text('Delete'),
        ),
      ),
    ];
  }

  void onSelected(String value) {
    switch (value) {
      case 'delete':
        deleteAction(widget.quotidian);
        break;
      default:
    }
  }

  void deleteAction(Quotidian quotidian) async {
    if (widget.onBeforeDelete != null) {
      widget.onBeforeDelete();
    }
    try {
      await FirebaseFirestore.instance
          .collection('quotidians')
          .doc(quotidian.id)
          .delete();

      if (widget.onAfterDelete != null) {
        widget.onAfterDelete(true);
      }

      Snack.s(
        context: context,
        message: "The quotidian has been successfully deleted.",
      );
    } catch (error) {
      debugPrint(error.toString());

      Snack.e(
        context: context,
        message: "Sorry, an error occurred while deleting the quotidian.",
      );

      if (widget.onAfterDelete != null) {
        widget.onAfterDelete(false);
      }
    }
  }

  double getHoverElevation() {
    return elevationSpecified ? widget.elevation * 2.0 : 2.0;
  }

  double getElevation() {
    return elevationSpecified ? widget.elevation : 0.0;
  }

  String getDate() {
    final date = widget.quotidian.date;

    String day = date.day < 10 ? '0${date.day}' : '${date.day}';
    String month = date.month < 10 ? '0${date.month}' : '${date.month}';
    String year = '${date.year}';

    return "$day/$month/$year";
  }

  void onTap(String quoteId) {
    context.router.root.push(
      QuotesDeepRoute(children: [
        QuotePageRoute(
          quoteId: quoteId,
        )
      ]),
    );
  }
}
