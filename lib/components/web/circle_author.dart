import 'package:flutter/material.dart';
import 'package:memorare/types/author.dart';
import 'package:supercharged/supercharged.dart';

import '../../screens/author_page.dart';

/// A widget which displays an author's image url
/// in an circle shape. Delivered with hover animation.
class CircleAuthor extends StatefulWidget {
  final Author author;
  final double size;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final Function itemBuilder;
  final Function onSelected;

  CircleAuthor({
    @required this.author,
    this.elevation = 3.0,
    this.padding = EdgeInsets.zero,
    this.size = 150.0,
    this.itemBuilder,
    this.onSelected,
  });

  @override
  _CircleAuthorState createState() => _CircleAuthorState();
}

class _CircleAuthorState extends State<CircleAuthor> {
  double size;
  double elevation;
  double opacity;

  @override
  initState() {
    super.initState();

    setState(() {
      size = widget.size;
      elevation = widget.elevation;
      opacity = 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        children: <Widget>[
          backgroundContainer(),
          name(),
          popupMenuButton(),
        ],
      ),
    );
  }

  Widget background() {
    final author = widget.author;
    final isImageOk = author.urls.image?.isNotEmpty;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: isImageOk
              ? Ink.image(
                  image: NetworkImage(author.urls.image),
                  fit: BoxFit.cover,
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80.0,
                    vertical: 40.0,
                  ),
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(
                      Icons.library_books,
                      size: 60.0,
                    ),
                  ),
                ),
        ),
        Positioned.fill(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AuthorPage(
                        id: author.id,
                      )));
            },
            onHover: (isHover) {
              if (isHover) {
                opacity = 0.0;
                size = widget.size + 2.5;
                elevation = widget.elevation + 2;
              } else {
                opacity = 0.5;
                size = widget.size;
                elevation = widget.elevation;
              }

              setState(() {});
            },
            child: Container(
              color: Color.fromRGBO(0, 0, 0, opacity),
            ),
          ),
        ),
      ],
    );
  }

  Widget backgroundContainer() {
    return AnimatedContainer(
      height: size,
      width: size,
      duration: 250.milliseconds,
      curve: Curves.bounceInOut,
      child: Material(
        elevation: elevation,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: background(),
      ),
    );
  }

  Widget name() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      width: 120.0,
      child: Opacity(
        opacity: 0.6,
        child: Text(
          widget.author.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    if (widget.itemBuilder == null || widget.onSelected == null) {
      return Padding(padding: EdgeInsets.zero);
    }

    return PopupMenuButton<String>(
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.more_horiz),
      ),
      onSelected: widget.onSelected,
      itemBuilder: widget.itemBuilder,
    );
  }
}
