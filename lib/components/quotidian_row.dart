import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/types/quotidian.dart';

class QuotidianRow extends StatefulWidget {
  final Function itemBuilder;
  final Function onSelected;
  final Quotidian quotidian;

  QuotidianRow({
    this.itemBuilder,
    this.onSelected,
    this.quotidian,
  });

  @override
  _QuotidianRowState createState() => _QuotidianRowState();
}

class _QuotidianRowState extends State<QuotidianRow> {
  double elevation = 0.0;
  Color iconColor;
  Color iconHoverColor;

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
      iconHoverColor = topicColor?.decimal != null
          ? Color(topicColor.decimal)
          : stateColors.primary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quotidian.quote;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 70.0,
        vertical: 30.0,
      ),
      child: Card(
        elevation: elevation,
        color: stateColors.appBackground,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => QuotePage(quoteId: quote.id)),
            );
          },
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
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Tooltip(
                    message:
                        'This quote will be shown on the ${widget.quotidian.date}',
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: stateColors.primary,
                      foregroundColor: Colors.white,
                      child: Text(
                        widget.quotidian.date.day.toString(),
                      ),
                    ),
                  ),
                ),
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    AuthorPage(id: quote.author.id)),
                          );
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
