import 'package:fig_style/state/colors.dart';
import 'package:flutter/material.dart';

class CreditItem extends StatefulWidget {
  final Function onTap;
  final IconData iconData;
  final Color hoverColor;
  final double opacity;
  final String textValue;

  const CreditItem({
    Key key,
    this.onTap,
    this.hoverColor,
    this.iconData,
    this.opacity = 0.6,
    @required this.textValue,
  }) : super(key: key);

  @override
  _CreditItemState createState() => _CreditItemState();
}

class _CreditItemState extends State<CreditItem> {
  Color baseColor;
  Color currentColor;
  Color hoverColor;

  @override
  void initState() {
    super.initState();
    setState(() {
      baseColor = stateColors.foreground.withOpacity(0.6);
      hoverColor = widget.hoverColor ?? currentColor;
      currentColor = baseColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (isHover) {
        if (isHover) {
          setState(() => currentColor = hoverColor);
          return;
        }

        setState(() => currentColor = baseColor);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 6.0,
        ),
        child: Row(
          children: <Widget>[
            if (widget.iconData != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  widget.iconData,
                  color: currentColor,
                ),
              ),
            Expanded(
              // child: widget.title,
              child: Opacity(
                opacity: widget.opacity,
                child: Text(
                  widget.textValue,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
