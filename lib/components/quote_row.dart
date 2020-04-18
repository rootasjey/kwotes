import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/quote.dart';

class QuoteRow extends StatelessWidget {
  final Quote quote;

  QuoteRow({this.quote});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column(
          children: <Widget>[
            ListTile(
              onLongPress: () {
                print('Copy quote name to clipboard.');
              },
              onTap: () {
                print('quote tapped: ${quote.id}');
              },
              title: Text(
                quote.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(top: 20.0, left: 15.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: CircleAvatar(
                        backgroundColor: Color(0xFFF56098),
                        backgroundImage: quote.author.imgUrl.length > 1 ?
                          NetworkImage(quote.author.imgUrl) :
                          AssetImage('assets/images/user-${stateColors.iconExt}.png'),
                        child: Text('${quote.author.name.substring(0,1)}'),
                      ),
                    ),
                    Text(
                      '${quote.author.name}',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                print('Navigate to author ${quote.author.id}');
              },
            ),
          ],
        ),
      ),
      onLongPress: () {
        print('show actions ui');
      },
    );
  }
}
