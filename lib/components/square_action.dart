import 'package:figstyle/state/colors.dart';
import 'package:flutter/material.dart';

class SquareAction extends StatelessWidget {
  final VoidCallback onTap;
  final String tooltip;
  final Widget icon;
  final Color borderColor;

  const SquareAction({
    Key key,
    this.onTap,
    @required this.icon,
    this.borderColor,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = 60.0;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(
              color: borderColor ?? stateColors.primary,
              width: 2.0,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Opacity(
                opacity: 0.8,
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
