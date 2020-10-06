import 'package:flutter/material.dart';

import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/reference_page.dart';
import 'package:memorare/screens/web/quote_page.dart';

class HorizontalCard extends StatefulWidget {
  final String authorId;
  final String authorName;
  final String quoteId;
  final String quoteName;
  final String referenceId;
  final String referenceName;

  HorizontalCard({
    this.authorId,
    this.authorName = '',
    this.quoteId,
    this.quoteName,
    this.referenceId,
    this.referenceName = '',
  });

  @override
  _HorizontalCardState createState() => _HorizontalCardState();
}

class _HorizontalCardState extends State<HorizontalCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700.0,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Card(
              child: InkWell(
                onTap: (widget.quoteId == null || widget.quoteId.length == 0)
                    ? null
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => QuotePage(
                                      quoteId: widget.quoteId,
                                    )));
                      },
                child: Padding(
                  padding: EdgeInsets.all(60.0),
                  child: Text(
                    widget.quoteName,
                    style: TextStyle(
                      fontSize: 27.0,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.authorName != null && widget.authorName.length > 0)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: FlatButton(
                  onPressed: () {
                    if (widget.authorId == null ||
                        widget.authorId.length == 0) {
                      return;
                    }

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AuthorPage(id: widget.authorId)));
                  },
                  child: Text(
                    widget.authorName,
                  ),
                ),
              ),
            if (widget.referenceName != null && widget.referenceName.length > 0)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: FlatButton(
                  onPressed: () {
                    if (widget.referenceId == null ||
                        widget.referenceId.length == 0) {
                      return;
                    }

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ReferencePage(id: widget.referenceId)));
                  },
                  child: Text(
                    widget.referenceName,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
