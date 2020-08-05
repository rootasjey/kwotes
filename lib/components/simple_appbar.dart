import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';

class SimpleAppBar extends StatefulWidget {
  /// If set, will be shown at the bottom of the title.
  final Widget subHeader;

  /// App bar title.
  final String textTitle;

  /// Will override [textTitle] if set.
  final Widget title;

  SimpleAppBar({
    this.subHeader,
    this.textTitle,
    this.title,
  });

  @override
  _SimpleAppBarState createState() => _SimpleAppBarState();
}

class _SimpleAppBarState extends State<SimpleAppBar> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: stateColors.appBackground.withOpacity(1.0),
          expandedHeight: 200.0,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FadeInY(
                delay: 1.0,
                beginY: 50.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 80.0,
                    top: 60.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          FluroRouter.router.pop(context);
                        },
                        tooltip: 'Back',
                        icon: Icon(Icons.arrow_back),
                      ),

                      Padding(padding: const EdgeInsets.only(right: 40.0)),

                      widget.title != null
                        ? widget.title
                        : Text(
                            widget.textTitle,
                            style: TextStyle(
                              fontSize: 40.0,
                            ),
                          ),
                    ],
                  ),
                ),
              ),

              if (widget.subHeader != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 165.0,
                  ),
                  child: widget.subHeader,
                ),
            ],
          ),
        );
      },
    );
  }
}
