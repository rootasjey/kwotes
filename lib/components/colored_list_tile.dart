import 'package:flutter/material.dart';
import 'package:figstyle/state/colors.dart';

class ColoredListTile extends StatefulWidget {
  final Color hoverColor;
  final IconData icon;
  final Function onTap;
  final bool outlined;
  final bool selected;
  final Widget title;
  final double width;

  const ColoredListTile({
    Key key,
    this.hoverColor,
    this.icon,
    this.onTap,
    this.outlined,
    this.selected,
    this.title,
    this.width,
  }) : super(key: key);

  @override
  _ColoredListTileState createState() => _ColoredListTileState();
}

class _ColoredListTileState extends State<ColoredListTile> {
  Color baseColor = Colors.black45;
  Color hoverColor = Colors.blue;
  Color currentColor = Colors.black45;

  @override
  void initState() {
    super.initState();

    setState(() {
      baseColor = widget.selected
          ? widget.hoverColor
          : stateColors.foreground.withOpacity(.5);

      hoverColor = widget.hoverColor;
      currentColor = baseColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (isHover) {
        setState(() {
          currentColor = isHover ? hoverColor : baseColor;
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
                    color: currentColor,
                  )
                : null,
            title: widget.title,
          ),
        ),
      ),
    );
  }
}
