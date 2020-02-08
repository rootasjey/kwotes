import 'package:flutter/material.dart';
import 'package:memorare/utils/router.dart';

class NavBackFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 200.0),
      child: FlatButton(
        onPressed: () {
          FluroRouter.router.pop(context);
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Text('Back'),
        ),
      ),
    );
  }
}
