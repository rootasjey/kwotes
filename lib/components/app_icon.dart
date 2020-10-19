import 'package:flutter/material.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/screens/home/home.dart';

class AppIcon extends StatefulWidget {
  final Function onTap;
  final EdgeInsetsGeometry padding;
  final double size;

  AppIcon({
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 80.0),
    this.size = 60.0,
  });

  @override
  _AppIconState createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Material(
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: AssetImage('assets/images/app-icon-64.png'),
          fit: BoxFit.cover,
          width: widget.size,
          height: widget.size,
          child: InkWell(
            onTap: widget.onTap ??
                () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Home())),
            onLongPress: () => showFooter(),
          ),
        ),
      ),
    );
  }

  void showFooter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Footer(
          closeModalOnNav: true,
        );
      },
    );
  }
}
