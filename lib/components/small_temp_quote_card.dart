
import 'package:flutter/material.dart';
import 'package:memorare/types/temp_quote.dart';

class SmallTempQuoteCard extends StatelessWidget {
  final TempQuote quote;
  final Function onLongPress;

  SmallTempQuoteCard({this.quote, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195.0,
      width: 200.0,
      child: Card(
        color: Color(0xFFF1F2F6),
        child: InkWell(
          onLongPress: () {
            if(onLongPress != null) {
              onLongPress(quote.id);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: Center(
              child: Text(
                (quote.name.length > 51) ?
                  '${quote.name.substring(0, 51)}...' :
                  quote.name,
                softWrap: true,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}
