import 'package:flutter/material.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

class QuoteCardGridItem extends StatefulWidget {
  final Quote quote;
  final Function onLongPress;
  final PopupMenuButton<String> popupMenuButton;
  final double elevation;

  QuoteCardGridItem({
    this.elevation = 0,
    this.onLongPress,
    this.popupMenuButton,
    this.quote,
  });

  @override
  _QuoteCardGridItemState createState() => _QuoteCardGridItemState();
}

class _QuoteCardGridItemState extends State<QuoteCardGridItem> {
  double _elevation = 0;

  @override
  initState() {
    super.initState();
    setState(() {
      _elevation = widget.elevation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _elevation,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          FluroRouter.router.navigateTo(
              context, QuotePageRoute.replaceFirst(':id', widget.quote.id));
        },
        onHover: (isHover) {
          if (isHover) {
            setState(() {
              _elevation = widget.elevation + 2.0;
            });
            return;
          }

          setState(() {
            _elevation = widget.elevation;
          });
        },
        onLongPress: widget.onLongPress,
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
                      fontSize: FontSize.gridItem(widget.quote.name),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.popupMenuButton != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: widget.popupMenuButton,
              ),
          ],
        ),
      ),
    );
  }
}
