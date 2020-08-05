import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';
import 'package:mobx/mobx.dart';

class ColoredListTile extends StatefulWidget {
  final Color hoverColor;
  final IconData icon;
  final Function onTap;
  final bool outlined;
  final bool selected;
  final Widget title;
  final double width;

  ColoredListTile({
    this.selected = false,
    this.hoverColor = Colors.blue,
    this.icon,
    this.onTap,
    this.outlined = true,
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
        baseColor = widget.selected
        ? widget.hoverColor
        : stateColors.foreground.withOpacity(.5);

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
          decoration: widget.outlined
            ? BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              border: Border.all(
                color: stateColors.foreground.withOpacity(0.2),
                width: 1.0,
              ),
            )
            : BoxDecoration(),
          child: ListTile(
            leading: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: hoverColor,
                )
              : null,
            title: widget.title,
          ),
        ),
      ),
    );
  }
}
