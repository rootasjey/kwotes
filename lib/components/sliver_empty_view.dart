import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/state/colors.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class SliverEmptyView extends StatelessWidget {
  final String descriptionString;
  final Widget icon;
  final String titleString;
  final Function onRefresh;
  final VoidCallback onTapDescription;

  SliverEmptyView({
    this.descriptionString = '',
    this.icon,
    this.onRefresh,
    this.onTapDescription,
    @required this.titleString,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(40.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Column(
            children: <Widget>[
              if (icon != null)
                FadeInY(
                  delay: 0.milliseconds,
                  beginY: 20.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Opacity(
                      opacity: 0.8,
                      child: icon,
                    ),
                  ),
                ),
              FadeInY(
                delay: 100.milliseconds,
                beginY: 20.0,
                child: Opacity(
                  opacity: 0.8,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Text(
                      titleString,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ),
              ),
              if (descriptionString != null && descriptionString.isNotEmpty)
                FadeInY(
                  delay: 200.milliseconds,
                  beginY: 20.0,
                  child: InkWell(
                    onTap: onTapDescription,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          descriptionString,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (onRefresh != null)
                FadeInY(
                  delay: 400.milliseconds,
                  beginY: 20.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: IconButton(
                      tooltip: "Refresh data",
                      onPressed: onRefresh,
                      icon: Icon(
                        UniconsLine.refresh,
                        color: stateColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ]),
      ),
    );
  }
}
