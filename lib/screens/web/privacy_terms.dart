import 'package:flutter/material.dart';
import 'package:memorare/components/web/nav_back_header.dart';

class PrivacyTerms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),
        SizedBox(
          width: 600.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Opacity(
                opacity: .8,
                child: Text(
                  'Cookies',
                  style: TextStyle(
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Opacity(
                opacity: .6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    'The application does not use cookies neither for user preferences nor tracking with id advertising.',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: .8,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: Text(
                    'Analytics',
                    style: TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: .6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    'The web & mobile apps collect usage data to improve the apps & services. However, personal data is never shared or sell to third parties.',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: .8,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: Text(
                    'Advertising',
                    style: TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: .6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    'The web & mobile apps may contain advertising to generate revenues. Advertisers may collect additional data on your navigation and preferences.',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: .8,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: Text(
                    'In-app purchases',
                    style: TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: .6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    'The apps contain in-app purchases which offer additional features.',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
