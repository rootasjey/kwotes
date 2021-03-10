import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/components/footer.dart';

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
          image: AssetImage('assets/images/app_icon/90.png'),
          fit: BoxFit.cover,
          width: widget.size,
          height: widget.size,
          child: InkWell(
            onTap:
                widget.onTap ?? () => context.router.root.navigate(HomeRoute()),
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
