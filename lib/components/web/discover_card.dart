import 'package:flutter/material.dart';

class DiscoverCard extends StatelessWidget {
  final String name;
  final String summary;
  final String type;

  DiscoverCard({
    this.name = '',
    this.summary = '',
    this.type = 'reference',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        height: 440.0,
        width: 270.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Opacity(
                      opacity: .7,
                      child: Text(
                        name.length < 21 ?
                          name : '${name.substring(0, 20)}...',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Opacity(
                          opacity: .5,
                          child: Text(
                            summary.length < 90 ?
                            summary : '${summary.substring(0, 90)}...',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        )
                      ),
                  ],
                ),

                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Opacity(
                    opacity: .6,
                    child: type == 'reference' ?
                      Icon(Icons.library_books, size: 30.0,) :
                      Icon(Icons.person_pin, size: 30.0,),
                  )
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
