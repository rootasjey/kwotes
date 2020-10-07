import 'package:flutter/material.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/enums.dart';
import 'package:memorare/types/temp_quote.dart';

class TempQuoteRow extends StatefulWidget {
  final bool isDraft;

  final double cardSize;
  final double elevation;

  final Function itemBuilder;
  final Function onSelected;
  final Function onTap;

  final ItemComponentType layout;
  final List<Widget> stackChildren;

  final TempQuote tempQuote;

  TempQuoteRow({
    this.cardSize = 250.0,
    this.elevation = 0.0,
    @required this.tempQuote,
    this.itemBuilder,
    this.isDraft = false,
    this.layout,
    this.onSelected,
    this.onTap,
    this.stackChildren = const [],
  });

  @override
  _TempQuoteRowState createState() => _TempQuoteRowState();
}

class _TempQuoteRowState extends State<TempQuoteRow> {
  double elevation = 0.0;
  Color iconColor;
  Color iconHoverColor;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.layout == ItemComponentType.row) {
      return rowLayout();
    }

    return cardLayout();
  }

  Widget rowLayout() {
    final quote = widget.tempQuote;
    final author = quote.author;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 70.0,
        vertical: 30.0,
      ),
      child: Card(
        elevation: elevation,
        color: stateColors.appBackground,
        child: InkWell(
          onTap: widget.onTap,
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
                if (widget.isDraft) draftInfo(),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.tempQuote.name,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(top: 10.0)),
                      GestureDetector(
                        onTap: () {
                          if (author == null ||
                              author.id == null ||
                              author.id.isEmpty) {
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => AuthorPage(id: author.id)),
                          );
                        },
                        child: Opacity(
                          opacity: .5,
                          child: Text(
                            author == null || author.name.isEmpty
                                ? ''
                                : author.name,
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

  Widget draftInfo() {
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

  Widget cardLayout() {
    final tempQuote = widget.tempQuote;

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
                  builder: (_) => AuthorPage(id: tempQuote.author.id)),
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
                      tempQuote.name.length > 115
                          ? '${tempQuote.name.substring(0, 115)}...'
                          : tempQuote.name,
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
}
