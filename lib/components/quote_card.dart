import 'package:flutter/material.dart';
import 'package:memorare/types/font_size.dart';
import 'package:supercharged/supercharged.dart';

class QuoteCard extends StatefulWidget {
  final Function onLongPress;
  final Function onTap;
  final PopupMenuButton<String> popupMenuButton;
  final double elevation;
  final String title;
  final double size;
  final List<Widget> stackChildren;

  QuoteCard({
    this.elevation = 0,
    this.onLongPress,
    this.onTap,
    this.popupMenuButton,
    this.size = 250.0,
    this.stackChildren = const [],
    this.title = '',
  });

  @override
  _QuoteCardState createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  double _elevation = 0;
  double _size;

  @override
  initState() {
    super.initState();
    setState(() {
      _elevation = widget.elevation;
      _size = widget.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: _size,
      height: _size,
      duration: 200.milliseconds,
      child: Card(
        elevation: _elevation,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: widget.onTap,
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
                      widget.title.length > 115
                          ? '${widget.title.substring(0, 115)}...'
                          : widget.title,
                      style: TextStyle(
                        fontSize: FontSize.gridItem(widget.title),
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

              if (widget.stackChildren.length > 0)
                ...widget.stackChildren,
            ],
          ),
        ),
      ),
    );
  }
}
