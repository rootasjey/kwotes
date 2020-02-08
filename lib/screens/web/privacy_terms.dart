import 'package:flutter/material.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class PrivacyTerms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
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
        ),

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

        Padding(
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
        ),
      ],
    );
  }
}
