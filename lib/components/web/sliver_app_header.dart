import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';

class SliverAppHeader extends StatelessWidget {
  final Widget bottomButton;
  final Function onScrollToTop;
  final Widget rightButton;
  final String subTitle;
  final String title;

  final double widthLimit = 500.0;

  SliverAppHeader({
    this.title,
    this.subTitle,
    this.bottomButton,
    this.rightButton,
    this.onScrollToTop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final top = width < widthLimit ? 50.0 : 85.0;
    final left = width < widthLimit ? 20.0 : 80.0;

    // Small screens
    if (width < widthLimit) {
      return Observer(
        builder: (context) {
          return SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: stateColors.softBackground,
            expandedHeight: 130.0,
            automaticallyImplyLeading: false,
            flexibleSpace: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FadeInY(
                      delay: 0.0,
                      beginY: 50.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 52.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: this.onScrollToTop,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 25.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (this.subTitle != null)
                      FadeInY(
                        delay: .5,
                        beginY: 50.0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 17.0),
                          child: Opacity(
                            opacity: .6,
                            child: Text(
                              this.subTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                  top: top,
                  child: this.rightButton,
                ),

                Positioned(
                  left: left,
                  top: top,
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

    // Large screens
    return Observer(
      builder: (context) {
        return SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: stateColors.softBackground,
          expandedHeight: width < widthLimit ? 150 : 320.0,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  FadeInY(
                    beginY: 50.0,
                    child: AppIconHeader(
                      padding: width < widthLimit ?
                        const EdgeInsets.only(top: 50.0, bottom: 20.0,) :
                        const EdgeInsets.symmetric(vertical: 80.0),
                    ),
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
                top: top,
                child: this.rightButton,
              ),

              Positioned(
                left: left,
                top: top,
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
