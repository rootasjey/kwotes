import 'package:flutter/material.dart';

class SliverEmptyView extends StatelessWidget {
  final String description;
  final Icon icon;
  final String title;
  final Widget subtitle;
  final Function onRefresh;
  final Function onTapDescription;
  final double maxWidth;

  SliverEmptyView({
    this.description = '',
    this.icon,
    this.onRefresh,
    this.onTapDescription,
    this.maxWidth = 600.0,
    @required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(40.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Container(
            width: maxWidth,
            child: Column(
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(title,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                Opacity(
                  opacity: 0.6,
                  child: subtitle,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: IconButton(
                    tooltip: "Retry",
                    icon: Icon(Icons.refresh),
                    onPressed: onRefresh,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget content(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (icon != null) icon,
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),
          Opacity(
              opacity: 0.6,
              child: FlatButton(
                onPressed: () {
                  if (onTapDescription != null) {
                    onTapDescription();
                  }
                },
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
