import 'package:flutter/material.dart';
import 'package:memorare/components/web/discover_card.dart';

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Text(
              'DISCOVER',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),

          SizedBox(
            width: 50.0,
            child: Divider(thickness: 2.0,),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'Learn knowledge about an author or a reference.'
              ),
            ),
          ),

          SizedBox(
            height: 440.0,
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 80.0
              ),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: <Widget>[
                DiscoverCard(
                  name: 'The 4-Hour Work Week',
                  summary: 'A book about taking control of your own life.',
                ),

                DiscoverCard(
                  name: 'Nowtech',
                  summary: 'Nowtech is a french content production about technology and applications. They produce a daily live on YouTube.',
                ),

                DiscoverCard(
                  name: 'Le Bourgeois gentilhomme',
                  summary: "Le Bourgeois gentilhomme is a five-act comédie-ballet — a play intermingled with music, dance and singing — written by Molière, first presented on 14 October 1670 before the court of Louis XIV at the Château of Chambord by Molière's troupe of actors.",
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
