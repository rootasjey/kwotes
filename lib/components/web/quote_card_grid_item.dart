import 'package:flutter/material.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

class QuoteCardGridItem extends StatelessWidget {
  final Quote quote;
  final Function onLongPress;
  final PopupMenuButton<String> popupMenuButton;

  QuoteCardGridItem({
    this.onLongPress,
    this.popupMenuButton,
    this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          FluroRouter.router.navigateTo(
            context,
            QuotePageRoute.replaceFirst(':id', quote.id)
          );
        },
        onLongPress: onLongPress,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    quote.name.length > 115 ?
                      '${quote.name.substring(0, 115)}...' : quote.name,
                    style: TextStyle(
                      fontSize: FontSize.gridItem(quote.name),
                    ),
                  ),
                ],
              ),
            ),

            if (popupMenuButton != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: popupMenuButton,
              ),
          ],
        ),
      ),
    );
  }
}
