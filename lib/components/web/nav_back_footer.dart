import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';

class NavBackFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 200.0),
      child: FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(color: stateColors.primary),
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
