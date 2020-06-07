import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';

class SliverAppHeader extends StatelessWidget {
  final String title;
  final Widget bottomButton;
  final Widget rightButton;

  SliverAppHeader({this.title, this.bottomButton, this.rightButton});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: stateColors.softBackground,
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

                  if (this.bottomButton != null)
                    FadeInY(
                      delay: .8,
                      beginY: 50.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: this.bottomButton,
                      ),
                    ),
                ],
              ),

              if (this.rightButton != null)
                Positioned(
                right: 20.0,
                top: 85.0,
                child: this.rightButton,
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
      },
    );
  }
}
