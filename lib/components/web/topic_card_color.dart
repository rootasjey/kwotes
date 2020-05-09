import 'package:flutter/material.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

class TopicCardColor extends StatelessWidget {
  final Color color;
  final String displayName;
  final double elevation;
  final String name;
  final Function onColorTap;
  final Function onTextTap;
  final bool outline;
  final double size;
  final TextStyle style;
  final String tooltip;

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
    final card = SizedBox(
      height: size,
      width: size,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: outline ? color : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: elevation,
        color: outline ? Colors.transparent : color,
        child: InkWell(
          onTap: () {
            if (onColorTap != null) {
              onColorTap();
              return;
            }

            FluroRouter.router.navigateTo(
              context,
              TopicRoute.replaceFirst(':name', name)
            );
          },
        ),
      ),
    );

    if (tooltip != null && tooltip.length > 0) {
      return withTooltip(child: card);
    }

    return card;
  }

  Widget cardName() {
    final text = Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Opacity(
        opacity: .5,
        child: InkWell(
          onTap: onTextTap,
          child: Text(
            displayName != null && displayName.length > 0 ?
              displayName : name,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip.length > 0) {
      return withTooltip(child: text);
    }

    return text;
  }

  Widget withTooltip({Widget child}) {
    return Tooltip(
      message: name,
      child: child,
    );
  }
}
