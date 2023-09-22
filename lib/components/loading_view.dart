import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

/// A sliver component to display when data is not ready yet.
class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message = "loading...",
  });

  /// Message value to display as a loading message.
  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/app_icon/animation.gif",
              width: 100.0,
            ),
            Text(
              message,
              style: Utils.calligraphy.body2(
                textStyle: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Return a Scaffold widget displaying a loading animation.
  static Widget scaffold({String message = "Loading..."}) {
    return Scaffold(
      body: Center(
        child: OverflowBox(
          maxHeight: 1200.0,
          maxWidth: 1200.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/app_icon/animation.gif",
                width: 100.0,
              ),
              Text(
                message,
                style: Utils.calligraphy.body2(
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
