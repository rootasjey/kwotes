import 'package:flutter/material.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/temp_quote.dart';

class TempQuoteCardGridItem extends StatelessWidget {
  final TempQuote tempQuote;
  final Function onLongPress;
  final Function onTap;
  final PopupMenuButton<String> popupMenuButton;

  TempQuoteCardGridItem({
    this.onLongPress,
    this.onTap,
    this.popupMenuButton,
    this.tempQuote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    tempQuote.name.length > 115 ?
                      '${tempQuote.name.substring(0, 115)}...' : tempQuote.name,
                    style: TextStyle(
                      fontSize: FontSize.gridItem(tempQuote.name),
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
