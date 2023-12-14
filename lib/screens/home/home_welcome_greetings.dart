import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class HomeWelcomeGreetings extends StatelessWidget {
  const HomeWelcomeGreetings({
    super.key,
    this.foregroundColor,
    this.padding = EdgeInsets.zero,
    this.refetchRandomQuotes,
  });

  /// Text foreground color.
  final Color? foregroundColor;

  /// Padding of the widget.
  final EdgeInsets padding;

  /// Callback fired to fetch new random quotes.
  final void Function()? refetchRandomQuotes;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: refetchRandomQuotes,
        child: Container(
          margin: padding,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 4.0,
                  height: 64.0,
                  foregroundDecoration: BoxDecoration(
                    color: foregroundColor?.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text.rich(
                  TextSpan(
                    text: "${"welcome.home.0".tr()}\n",
                    children: [
                      TextSpan(
                        text: "${"welcome.home.1".tr()}\n",
                      ),
                      TextSpan(
                        text: "welcome.home.2".tr(),
                      ),
                    ],
                  ),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      color: foregroundColor?.withOpacity(0.4),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                    ),
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
