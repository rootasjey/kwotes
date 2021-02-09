import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class TopicCardColor extends StatefulWidget {
  final bool outline;

  final Color color;

  final double elevation;
  final double size;

  final EdgeInsets padding;

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
    this.padding = EdgeInsets.zero,
    this.size = 70.0,
    this.style,
    this.tooltip,
  });

  @override
  _TopicCardColorState createState() => _TopicCardColorState();
}

class _TopicCardColorState extends State<TopicCardColor>
    with TickerProviderStateMixin {
  Animation<double> scaleAnimation;
  AnimationController scaleAnimationController;

  @override
  void initState() {
    super.initState();

    scaleAnimationController = AnimationController(
      lowerBound: 0.6,
      upperBound: 1.0,
      duration: 250.milliseconds,
      vsync: this,
    );

    scaleAnimation = CurvedAnimation(
      parent: scaleAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        children: <Widget>[
          cardColor(context: context),
          cardName(),
        ],
      ),
    );
  }

  @override
  dispose() {
    scaleAnimationController?.dispose();
    super.dispose();
  }

  Widget cardColor({BuildContext context}) {
    final card = ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        height: widget.size,
        width: widget.size,
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

              context.router.root.push(
                TopicsDeepRoute(
                  children: [
                    TopicPageRoute(
                      topicName: widget.name,
                    )
                  ],
                ),
              );
            },
            onHover: (isHover) {
              if (isHover) {
                scaleAnimationController.forward();
              } else {
                scaleAnimationController.reverse();
              }
            },
          ),
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
      message: widget.tooltip,
      child: child,
    );
  }
}
