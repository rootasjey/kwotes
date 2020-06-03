import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/router.dart';

class SliverAppHeader extends StatelessWidget {
  final String title;

  SliverAppHeader({this.title,});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 320.0,
      automaticallyImplyLeading: false,
      flexibleSpace: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              FadeInY(
                beginY: 50.0,
                child: AppIconHeader(),
              ),

              FadeInY(
                delay: 1.0,
                beginY: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            left: 80.0,
            top: 85.0,
            child: IconButton(
              onPressed: () {
                FluroRouter.router.pop(context);
              },
              tooltip: 'Back',
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }
}
