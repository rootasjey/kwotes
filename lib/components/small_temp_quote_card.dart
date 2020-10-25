import 'package:flutter/material.dart';
import 'package:figstyle/types/temp_quote.dart';

class SmallTempQuoteCard extends StatefulWidget {
  final Function onDelete;
  final Function onDoubleTap;
  final Function onTap;
  final Function onEdit;
  final Function onLongPress;
  final Function onValidate;
  final TempQuote quote;

  SmallTempQuoteCard({
    this.onDelete,
    this.onDoubleTap,
    this.onTap,
    this.onEdit,
    this.onLongPress,
    this.onValidate,
    this.quote,
  });

  @override
  _SmallTempQuoteCardState createState() => _SmallTempQuoteCardState();
}

class _SmallTempQuoteCardState extends State<SmallTempQuoteCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195.0,
      width: 200.0,
      child: Card(
        child: Stack(
          children: [
            InkWell(
              onLongPress: () {
                if (widget.onLongPress != null) {
                  widget.onLongPress(widget.quote.id);
                }
              },
              onDoubleTap: () {
                if (widget.onDoubleTap != null) {
                  widget.onDoubleTap(widget.quote.id);
                }
              },
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap(widget.quote.id);
                }
              },
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Center(
                  child: Text(
                    (widget.quote.name.length > 51) ?
                      '${widget.quote.name.substring(0, 51)}...' :
                      widget.quote.name,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              right: 0,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'delete' && widget.onDelete != null) {
                    widget.onDelete(widget.quote.id);
                    return;
                  }

                  if (value == 'edit' && widget.onEdit != null) {
                    widget.onEdit(widget.quote.id);
                    return;
                  }

                  if (value == 'validate' && widget.onValidate != null) {
                    widget.onValidate(widget.quote.id);
                    return;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem(
                    value: 'validate',
                    child: ListTile(
                      leading: Icon(Icons.check),
                      title: Text(
                        'Validate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text(
                        'Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ),
                ],
              ),
            ),
          ]
        )
      ),
    );
  }
}
