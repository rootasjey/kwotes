import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';
import 'package:mobx/mobx.dart';

class ColoredListTile extends StatefulWidget {
  final Color hoverColor;
  final IconData icon;
  final Widget title;
  final double width;
  final Function onTap;

  ColoredListTile({
    this.hoverColor = Colors.blue,
    this.icon,
    this.onTap,
    this.title,
    this.width = 200.0,
  });

  @override
  _ColoredListTileState createState() => _ColoredListTileState();
}

class _ColoredListTileState extends State<ColoredListTile> {
  Color hoverColor = Colors.black45;
  Color baseColor = Colors.black45;

  ReactionDisposer colorDisposer;

  @override
  void initState() {
    super.initState();

    colorDisposer = autorun((reaction) {
      setState(() {
        baseColor = stateColors.foreground;
        hoverColor = baseColor;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (colorDisposer != null) {
      colorDisposer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (isHover) {
        if (isHover) {
          setState(() {
            hoverColor = widget.hoverColor;
          });

          return;
        }

        setState(() {
          hoverColor = baseColor;
        });
      },
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.0),
            border: Border.all(
              color: stateColors.foreground,
              width: 1.0,
            ),
          ),
          child: ListTile(
            leading: Icon(
              widget.icon,
              color: hoverColor,
            ),
            title: widget.title,
          ),
        ),
      ),
    );
  }
}
