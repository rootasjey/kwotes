
import 'package:flutter/material.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';

class MediumQuoteCard extends StatelessWidget {
  final Quote quote;

  MediumQuoteCard({this.quote});

  @override
  Widget build(BuildContext context) {
    final topicColor = quote.topics.length > 0 ?
      ThemeColor.topicColor(quote.topics.first) :
      ThemeColor.primary;

    return SizedBox(
      height: 330.0,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 300.0,
            child: Card(
              color: topicColor,
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Center(
                    child: Text(
                      '${quote.name}',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return QuotePage(quoteId: quote.id,);
                      }
                    )
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 30.0,
            child: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                quote.author.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}
