import 'package:flutter/material.dart';
import 'package:memorare/components/web/horizontal_card.dart';

class PreviousQuotidians extends StatefulWidget {
  @override
  _PreviousQuotidiansState createState() => _PreviousQuotidiansState();
}

class _PreviousQuotidiansState extends State<PreviousQuotidians> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500.0,
      child: Container(
        decoration: BoxDecoration(color: Color(0xFFEDEDEC)),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Text(
                'YESTERDAY',
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
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Opacity(
                opacity: .6,
                child: Text(
                  'Quotes of the past.'
                ),
              ),
            ),

            HorizontalCard(
              name: 'Lourd est le parpaing sur la tartelette à la fraise de nos illusions.',
              authorName: 'Someone on the internet',
            ),
          ],
        ),
      )
    );
  }
}
