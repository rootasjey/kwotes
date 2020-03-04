import 'package:flutter/material.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class TopicCardColor extends StatelessWidget {
  final String name;
  final Color color;

  TopicCardColor({
    this.color,
    this.name = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 70.0,
            width: 70.0,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: color,
              child: InkWell(
                onTap: () {
                  FluroRouter.router.navigateTo(
                    context,
                    TopicRoute.replaceFirst(':name', name)
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Opacity(
              opacity: .5,
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
