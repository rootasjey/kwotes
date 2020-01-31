import 'package:flutter/material.dart';

class FullPageQuotidian extends StatefulWidget {
  @override
  _FullPageQuotidianState createState() => _FullPageQuotidianState();
}

class _FullPageQuotidianState extends State<FullPageQuotidian> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height - 50.0,
          child: Padding(
            padding: EdgeInsets.all(70.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Une fois en orbite, on est à mi-chemin de partout ailleurs.',
                  style: TextStyle(
                    fontSize: 80.0,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: SizedBox(
                    width: 200.0,
                    child: Divider(
                      color: Color(0xFF64C7FF),
                      thickness: 2.0,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Opacity(
                    opacity: .8,
                    child: Text(
                      'Un internaute inspiré',
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  )
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Opacity(
                    opacity: .6,
                    child: Text(
                      'La référence inoubliable',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () { print('fav'); },
                icon: Icon(Icons.favorite_border),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: IconButton(
                  onPressed: () { print('share'); },
                  icon: Icon(Icons.share),
                ),
              ),

              IconButton(
                onPressed: () { print('add list'); },
                icon: Icon(Icons.playlist_add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
