import 'package:figstyle/state/colors.dart';
import 'package:flutter/material.dart';

class TileButton extends StatelessWidget {
  final IconData iconData;
  final String textTitle;
  final VoidCallback onTap;
  final Widget trailing;

  const TileButton({
    Key key,
    @required this.iconData,
    @required this.textTitle,
    @required this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 30.0),
      leading: Padding(
        padding: const EdgeInsets.only(
          bottom: 6.0,
        ),
        child: Icon(
          iconData,
          color: stateColors.primary,
        ),
      ),
      title: Text(
        textTitle,
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
