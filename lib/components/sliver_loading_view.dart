import 'package:flutter/material.dart';
import 'package:figstyle/components/loading_animation.dart';

class SliverLoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 200.0),
          child: LoadingAnimation(),
        ),
      ]),
    );
  }
}
