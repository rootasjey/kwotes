import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 60.0,
        vertical: 100.0,
      ),
      color: Color(0xFFE6E6E6),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 30.0,
                  left: 15.0
                ),
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'LANGUAGE',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),

              FlatButton(
                onPressed: () {},
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'English',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: () {},
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'Français',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 30.0,
                  left: 15.0
                ),
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'DEVELOPERS',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),

              FlatButton(
                onPressed: null,
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'Documentation',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: null,
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'API References',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: null,
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'API Status',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: () {},
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'GitHub',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 30.0,
                  left: 15.0
                ),
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'RESOURCES',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),

              FlatButton(
                onPressed: () {},
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: () {},
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'Contact',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: () {},
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'Privacy & Terms',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),

              FlatButton(
                onPressed: () {},
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    'Sitemap',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
