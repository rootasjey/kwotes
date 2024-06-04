import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

/// A sliver component to display when data is not ready yet.
class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message = "Loading...",
    this.useSliver = true,
  });

  /// Message value to display as a loading message.
  final String message;

  /// If true, it will display a sliver.
  /// Default to true.
  final bool useSliver;

  @override
  Widget build(BuildContext context) {
    final Widget child = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/app_icon/animation.gif",
            width: 100.0,
          ),
          Text(
            message,
            style: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (!useSliver) {
      return child;
    }

    return SliverToBoxAdapter(
      child: child,
    );
  }

  /// Return a Scaffold widget displaying a loading animation.
  static Widget scaffold({
    String message = "Loading...",
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Scaffold(
      body: Padding(
        padding: margin,
        child: Center(
          child: OverflowBox(
            maxHeight: 1200.0,
            // maxWidth: 1200.0, // why?
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/app_icon/animation.gif",
                  width: 100.0,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Utils.calligraphy.body(
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
      ),
    );
  }
}
