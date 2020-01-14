import 'package:flutter/material.dart';
import 'package:memorare/components/add_to_list_button.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:share/share.dart';

class MediumQuoteCard extends StatelessWidget {
  final Color color;
  final Function onLike;
  final Function onUnlike;
  final Function onRemove;
  final String onRemoveText;
  final Orientation orientation;
  final Quote quote;

  MediumQuoteCard({
    this.color,
    this.onRemove,
    this.onRemoveText,
    this.onLike,
    this.onUnlike,
    this.orientation = Orientation.portrait,
    this.quote,
  });

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
      height: orientation == Orientation.portrait ?
        330.0 : 280.0,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: orientation == Orientation.portrait ?
              300.0 : 250.0,
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
                  id: quote.author.id,
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
    final starred = quote.starred;

    return Positioned(
      bottom: 0,
      right: 0,
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_horiz),
        onSelected: (value) async {
          if (value == 'like') {
            if (onLike != null) { onLike(); }
            return;
          }

          if (value == 'unlike') {
            if (onUnlike != null) { onUnlike(); }
            return;
          }

          if (value == 'addTo') {
            return;
          }

          if (value == 'share') {
            return;
          }

          if (value == 'remove') {
            if (onRemove != null) { onRemove(); }
            return;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: 'addTo',
            child: AddToListButton(
              context: context,
              quoteId: quote.id,
              type: ButtonType.tile,
              onBeforeShowSheet: () => Navigator.pop(context),
            ),
          ),
          PopupMenuItem(
            value: 'share',
            child: ListTile(
              onTap: () {
                Navigator.pop(context);

                final RenderBox box = context.findRenderObject();
                final sharingText = quote.author != null ?
                  '${quote.name} - ${quote.author.name}' :
                  quote.name;

                Share.share(
                  sharingText,
                  subject: 'Memorare quote',
                  sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                );
              },
              leading: Icon(Icons.share),
              title: Text(
                'Share',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          if (!starred)
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
          if (starred)
            const PopupMenuItem(
              value: 'unlike',
              child: ListTile(
                leading: Icon(Icons.favorite),
                title: Text(
                  'Unlike',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),
          if (onRemove != null)
            PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text(
                  onRemoveText ?? 'Remove',
                  overflow: TextOverflow.ellipsis,
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
