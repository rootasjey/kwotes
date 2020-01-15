import 'package:flutter/material.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:provider/provider.dart';

class SmallQuoteCard extends StatelessWidget {
  final Quote quote;

  SmallQuoteCard({this.quote});

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeColor>(context);

    final topicColor = quote.topics.length > 0 ?
      ThemeColor.topicColor(quote.topics.first) :
      themeColor.accent;

    return SizedBox(
      height: 200.0,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 185.0,
            width: 200.0,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
                side: BorderSide(
                  color: topicColor,
                  width: 2.0,
                )
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return QuotePage(quoteId: quote.id,);
                      }
                    )
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(20.0),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
