import 'package:flutter/material.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class AppIconHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0),
      child: InkWell(
        onTap: () {
          FluroRouter.router.navigateTo(context, HomeRoute);
        },
        borderRadius: BorderRadius.circular(50.0),
        child: Image(
          image: AssetImage('assets/images/icon-small.png'),
          width: 90.0,
          height: 90.0,
        ),
      ),
    );
  }
}
