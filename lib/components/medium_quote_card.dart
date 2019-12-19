import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';

class MediumQuoteCard extends StatelessWidget {
  final Quote quote;
  final Color color;

  MediumQuoteCard({this.color, this.quote});

  @override
  Widget build(BuildContext context) {
    Color topicColor;

    if (color != null) { topicColor = color; }
    else {
      topicColor = quote.topics.length > 0 ?
        ThemeColor.topicColor(quote.topics.first) :
        ThemeColor.primary;
    }

    return SizedBox(
      height: 330.0,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 300.0,
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
                side: BorderSide(
                  color: topicColor,
                  width: 5.0,
                )
              ),
              child: Stack(
                children: <Widget>[
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Center(
                        child: Text(
                          '${quote.name}',
                          style: TextStyle(
                            fontSize: FontSize.mediumCard(quote.name),
                            fontWeight: FontWeight.bold,
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

                  moreButton(context),

                ],
              )
            ),
          ),

          if (quote.author != null)
            authorElement(context),

          if (quote.references != null && quote.references.length > 0)
            referenceElement(context),
        ],
      ),
    );
  }

  Widget authorElement(BuildContext context) {
    return SizedBox(
      height: 30.0,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            quote.author.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AuthorPage(
                  authorId: quote.author.id,
                  authorName: quote.author.name,
                );
              }
            )
          );
        },
      )
    );
  }

  Widget moreButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_horiz),
        onSelected: (value) async {
          if (value == 'like') {
            final booleanMessage = await UserMutations.star(context, quote.id);

            Flushbar(
              duration: Duration(seconds: 2),
              backgroundColor: booleanMessage.boolean ?
                ThemeColor.success :
                ThemeColor.error,
              message: booleanMessage.boolean ?
                'The quote has been successfully lked.':
                booleanMessage.message,
            )..show(context);

            return;
          }

          if (value == 'addTo') {
            return;
          }

          if (value == 'share') {
            return;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem(
            value: 'addTo',
            child: ListTile(
              leading: Icon(Icons.playlist_add),
              title: Text(
                'Add to...',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          const PopupMenuItem(
            value: 'share',
            child: ListTile(
              leading: Icon(Icons.share),
              title: Text(
                'Share',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          const PopupMenuItem(
            value: 'like',
            child: ListTile(
              leading: Icon(Icons.favorite_border),
              title: Text(
                'Like',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget referenceElement(BuildContext context) {
    return SizedBox(
      height: 30.0,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            quote.references.first.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700
            ),
          ),
        ),
        onTap: () {},
      )
    );
  }
}
