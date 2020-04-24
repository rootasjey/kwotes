import 'package:flutter/material.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

class TopicCardColor extends StatelessWidget {
  final Color color;
  final String displayName;
  final double elevation;
  final String name;
  final double size;
  final TextStyle style;
  final Function onColorTap;
  final Function onTextTap;

  TopicCardColor({
    this.color,
    this.displayName = '',
    this.elevation = 1.0,
    this.name = '',
    this.onColorTap,
    this.onTextTap,
    this.size = 70.0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: size,
            width: size,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: elevation,
              color: color,
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
          ),

          Padding(
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
          ),
        ],
      ),
    );
  }
}
