import 'package:flutter/material.dart';
import 'package:figstyle/screens/topic_page.dart';
import 'package:supercharged/supercharged.dart';

class TopicCardColor extends StatefulWidget {
  final bool outline;

  final Color color;

  final double elevation;
  final double size;

  final Function onColorTap;
  final Function onTextTap;

  final String displayName;
  final String name;
  final String tooltip;

  final TextStyle style;

  TopicCardColor({
    this.color,
    this.displayName = '',
    this.elevation = 1.0,
    this.name = '',
    this.onColorTap,
    this.onTextTap,
    this.outline = false,
    this.size = 70.0,
    this.style,
    this.tooltip,
  });

  @override
  _TopicCardColorState createState() => _TopicCardColorState();
}

class _TopicCardColorState extends State<TopicCardColor> {
  double growSize = 0.0;
  double size;

  @override
  void initState() {
    super.initState();
    size = widget.size;
    growSize = widget.size + 5.0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          cardColor(context: context),
          cardName(),
        ],
      ),
    );
  }

  Widget cardColor({BuildContext context}) {
    final card = AnimatedContainer(
      height: size,
      width: size,
      duration: 250.milliseconds,
      curve: Curves.bounceInOut,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: widget.outline ? widget.color : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: widget.elevation,
        color: widget.outline ? Colors.transparent : widget.color,
        child: InkWell(
          onTap: () {
            if (widget.onColorTap != null) {
              widget.onColorTap();
              return;
            }

            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TopicPage(name: widget.name)));
          },
          onHover: (isHover) {
            if (isHover) {
              size = growSize;
            } else {
              size = widget.size;
            }

            setState(() {});
          },
        ),
      ),
    );

    if (widget.tooltip != null && widget.tooltip.length > 0) {
      return withTooltip(child: card);
    }

    return card;
  }

  Widget cardName() {
    final text = Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Opacity(
        opacity: 0.5,
        child: InkWell(
          onTap: widget.onTextTap,
          child: Text(
            widget.displayName != null && widget.displayName.length > 0
                ? widget.displayName
                : widget.name,
            overflow: TextOverflow.ellipsis,
            style: widget.style,
          ),
        ),
      ),
    );

    if (widget.tooltip != null && widget.tooltip.length > 0) {
      return withTooltip(child: text);
    }

    return text;
  }

  Widget withTooltip({Widget child}) {
    return Tooltip(
      message: widget.name,
      child: child,
    );
  }
}
