import 'package:flutter/material.dart';
import 'package:figstyle/components/main_app_bar.dart';

class PrivacyTerms extends StatelessWidget {
  final double titleFontSize = 16.0;
  final double textFontSize = 20.0;
  final FontWeight titleFontWeight = FontWeight.w600;
  final double titleOpacity = 0.6;
  final double textOpacity = 0.8;
  final double topPadding = 40.0;

  @override
  Widget build(BuildContext context) {
    final horPadding = MediaQuery.of(context).size.width < 700.0 ? 20 : 80.0;

    return Scaffold(
        body: CustomScrollView(
      slivers: [
        MainAppBar(
          title: "Privacy Terms",
          automaticallyImplyLeading: true,
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horPadding, vertical: 60.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              SizedBox(
                width: 600.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    cookiesBlock(),
                    analyticsBlock(),
                    advertisingBlock(),
                    inAppPurchasesBlock(),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    ));
  }

  Widget cookiesBlock() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Opacity(
        opacity: titleOpacity,
        child: Text(
          'COOKIES',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: titleFontWeight,
          ),
        ),
      ),
      Opacity(
        opacity: textOpacity,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            'The application does not use cookies neither for user preferences nor tracking with id advertising.',
            style: TextStyle(
              fontSize: textFontSize,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget analyticsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: titleOpacity,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Text(
              'ANALYTICS',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: titleFontWeight,
              ),
            ),
          ),
        ),
        Opacity(
          opacity: textOpacity,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              'The web & mobile apps collect usage data to improve the apps & services. However, personal data is never shared or sell to third parties.',
              style: TextStyle(
                fontSize: textFontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget advertisingBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: titleOpacity,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Text(
              'ADVERTISING',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: titleFontWeight,
              ),
            ),
          ),
        ),
        Opacity(
          opacity: textOpacity,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              'The web & mobile apps may contain advertising to generate revenues. Advertisers may collect additional data on your navigation and preferences.',
              style: TextStyle(
                fontSize: textFontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget inAppPurchasesBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: titleOpacity,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Text(
              'IN-APP PURCHASES',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: titleFontWeight,
              ),
            ),
          ),
        ),
        Opacity(
          opacity: textOpacity,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              'The apps contain in-app purchases which offer additional features.',
              style: TextStyle(
                fontSize: textFontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
