import 'package:flutter/material.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/quote.dart';

class QuoteRow extends StatefulWidget {
  final Quote quote;

  /// Specify explicitly the quote'is
  /// because quote's id in favourites reflect
  /// the favourite's id and no the quote.
  final String quoteId;
  final PopupMenuButton popupMenuButton;
  final Function itemBuilder;
  final Function onSelected;

  QuoteRow({
    this.quote,
    this.quoteId,
    this.popupMenuButton,
    this.itemBuilder,
    this.onSelected,
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
    final topicColor = appTopicsColors.find(widget.quote.topics.first);

    setState(() {
      iconHoverColor = Color(topicColor.decimal);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            // print(widget.quote.quoteId);
            FluroRouter.router.navigateTo(
              context,
              QuotePageRoute.replaceFirst(':id', widget.quoteId),
            );
          },
          onHover: (isHover) {
            elevation = isHover
              ? 2.0
              : 0.0;

            iconColor = isHover
              ? iconHoverColor
              : null;

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
                        widget.quote.name,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),

                      Padding(padding: const EdgeInsets.only(top: 10.0)),

                      GestureDetector(
                        onTap: () {
                          FluroRouter.router.navigateTo(
                            context,
                            AuthorRoute.replaceFirst(':id', widget.quote.author.id),
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
                            ? Icon(Icons.more_vert, color: iconColor,)
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
