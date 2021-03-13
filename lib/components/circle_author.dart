import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/types/author.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A widget which displays an author's image url
/// in an circle shape. Delivered with hover animation.
class CircleAuthor extends StatefulWidget {
  final Author author;
  final double elevation;
  final Function itemBuilder;
  final Function onSelected;
  final EdgeInsetsGeometry padding;
  final double size;
  final double titleFontSize;

  CircleAuthor({
    @required this.author,
    this.elevation = 3.0,
    this.itemBuilder,
    this.onSelected,
    this.padding = EdgeInsets.zero,
    this.size = 150.0,
    this.titleFontSize = 18.0,
  });

  @override
  _CircleAuthorState createState() => _CircleAuthorState();
}

class _CircleAuthorState extends State<CircleAuthor>
    with TickerProviderStateMixin {
  Animation<double> scaleAnimation;
  AnimationController scaleAnimationController;

  double size;
  double elevation;
  double opacity;

  @override
  initState() {
    super.initState();

    scaleAnimationController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: 500.milliseconds,
      vsync: this,
    );

    scaleAnimation = CurvedAnimation(
      parent: scaleAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    setState(() {
      size = widget.size;
      elevation = widget.elevation;
      opacity = 0.5;
    });
  }

  @override
  dispose() {
    scaleAnimationController.dispose();
    super.dispose();
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
              : Opacity(
                  opacity: 0.6,
                  child: Icon(
                    UniconsLine.user,
                    size: 60.0,
                  ),
                ),
        ),
        Positioned.fill(
          child: InkWell(
            onTap: () => onTap(author),
            onHover: (isHover) {
              if (isHover) {
                opacity = 0.0;
                elevation = widget.elevation + 2;
                scaleAnimationController.forward();
              } else {
                opacity = 0.5;
                elevation = widget.elevation;
                scaleAnimationController.reverse();
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
    return SizedBox(
      height: size,
      width: size,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Material(
          elevation: elevation,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
          child: background(),
        ),
      ),
    );
  }

  Widget name() {
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      width: 120.0,
      child: Opacity(
        opacity: 0.6,
        child: Text(
          widget.author.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: widget.titleFontSize,
          ),
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    if (widget.itemBuilder == null || widget.onSelected == null) {
      return Container();
    }

    return PopupMenuButton<String>(
      icon: Opacity(
        opacity: 0.6,
        child: Icon(Icons.more_horiz),
      ),
      onSelected: widget.onSelected,
      itemBuilder: widget.itemBuilder,
    );
  }

  void onTap(Author author) {
    context.router.push(
      AuthorsDeepRoute(
        children: [
          AuthorPageRoute(
            authorId: author.id,
            authorImageUrl: author.urls.image,
            authorName: author.name,
          ),
        ],
      ),
    );
  }
}
