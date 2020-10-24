import 'package:flutter/material.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/author.dart';

class AuthorRow extends StatefulWidget {
  final Author author;

  final Function itemBuilder;
  final Function onSelected;

  final EdgeInsets padding;

  AuthorRow({
    this.author,
    this.itemBuilder,
    this.onSelected,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
  });

  @override
  _AuthorRowState createState() => _AuthorRowState();
}

class _AuthorRowState extends State<AuthorRow> {
  double elevation = 0.0;
  Color iconColor;
  Color iconHoverColor;

  @override
  initState() {
    super.initState();

    setState(() {
      iconHoverColor = stateColors.primary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.author;

    return Container(
      padding: widget.padding,
      child: Card(
        elevation: elevation,
        color: stateColors.appBackground,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AuthorPage(id: author.id)),
            );
          },
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? 2.0 : 0.0;
              iconColor = isHover ? iconHoverColor : null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                avatar(author),
                title(author),
                actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget actions() {
    return SizedBox(
      width: 50.0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PopupMenuButton<String>(
            icon: Opacity(
              opacity: .6,
              child: iconColor != null
                  ? Icon(
                      Icons.more_vert,
                      color: iconColor,
                    )
                  : Icon(Icons.more_vert),
            ),
            onSelected: widget.onSelected,
            itemBuilder: widget.itemBuilder,
          ),
        ],
      ),
    );
  }

  Widget avatar(Author author) {
    final isImageOk = author.urls.image?.isNotEmpty;

    if (!isImageOk) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Padding(
        padding: const EdgeInsets.only(right: 40.0),
        child: Material(
          elevation: 4.0,
          shape: CircleBorder(),
          child: Opacity(
            opacity: elevation > 0.0 ? 1.0 : 0.8,
            child: Image.network(
              author.urls.image,
              width: 80.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
          ),
        ));
  }

  Widget title(Author author) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            author.name,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          if (author.job?.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: OutlinedButton.icon(
                onPressed: null,
                icon: Icon(Icons.work_outline),
                label: Text(
                  author.job,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
