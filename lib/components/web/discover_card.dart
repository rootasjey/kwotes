import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:supercharged/supercharged.dart';

class DiscoverCard extends StatefulWidget {
  final double elevation;
  final double height;
  final String id;
  final String imageUrl;
  final String name;
  final EdgeInsetsGeometry padding;
  final String summary;
  final double textHeight;
  final double titleFontSize;
  final String type;
  final double width;

  DiscoverCard({
    this.id,
    this.imageUrl = '',
    this.name     = '',
    this.summary  = '',
    this.type     = 'reference',
    this.height   = 350.0,
    this.width    = 270.0,
    this.padding  = EdgeInsets.zero,
    this.textHeight = 70,
    this.titleFontSize = 20.0,
    this.elevation = 3.0,
  });

  @override
  _DiscoverCardState createState() => _DiscoverCardState();
}

class _DiscoverCardState extends State<DiscoverCard> {
  double opacity = 0.5;
  double width;
  double height;
  double elevation;
  double textHeight;
  double textOpacity = 0.0;
  EdgeInsetsGeometry assetImgPadding;

  @override
  initState() {
    super.initState();

    setState(() {
      width = widget.width;
      height = widget.height;
      textHeight = widget.textHeight;
      elevation = widget.elevation;

      assetImgPadding = width > 300.0 ?
        const EdgeInsets.symmetric(
          horizontal: 80.0,
          vertical: 40.0,
        ) :
        const EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 20.0,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: AnimatedContainer(
        height: height,
        width: width,
        duration: 250.milliseconds,
        curve: Curves.bounceInOut,
        child: Card(
          elevation: elevation,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            children: <Widget>[
              ...background(),
              texts(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> background() {
    final isImageOk = widget.imageUrl != null &&
      widget.imageUrl.length > 0;

    return [
      Positioned.fill(
        child: isImageOk ?
        Ink.image(
          image: NetworkImage(widget.imageUrl),
          fit: BoxFit.cover,
        ) :
        Padding(
          padding: assetImgPadding,
          child: Observer(
            builder: (context) {
              return Image.asset(
                widget.type == 'reference' ?
                'assets/images/textbook-${stateColors.iconExt}.png' :
                'assets/images/profile-${stateColors.iconExt}.png',
                alignment: Alignment.topCenter,
              );
            }
          )
        ),
      ),

      Positioned.fill(
        child: InkWell(
          onTap: () {
            final route = widget.type == 'reference' ?
              ReferenceRoute.replaceFirst(':id', widget.id) :
              AuthorRoute.replaceFirst(':id', widget.id);

            FluroRouter.router.navigateTo(
              context,
              route,
            );
          },
          onHover: (isHover) {
            if (isHover) {
              opacity = 0.0;
              width = widget.width + 10.0;
              height = widget.height + 10.0;
              elevation = widget.elevation + 2;
            }
            else {
              opacity = 0.5;
              width = widget.width;
              height = widget.height;
              elevation = widget.elevation;
            }

            setState(() {});
          },
          child: Container(
            color: Color.fromRGBO(0, 0, 0, opacity),
          ),
        ),
      ),
    ];
  }

  Widget texts() {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      child: InkWell(
        onTap: () {
          final route = widget.type == 'reference' ?
            ReferenceRoute.replaceFirst(':id', widget.id) :
            AuthorRoute.replaceFirst(':id', widget.id);

          FluroRouter.router.navigateTo(
            context,
            route,
          );
        },
        onHover: (isHover) {
          if (isHover) {
            textHeight = widget.textHeight * 2;
            textOpacity = .3;
          } else {
            textHeight = widget.textHeight;
            textOpacity = .0;
          }

          setState(() {});
        },
        child: AnimatedContainer(
          width: width,
          height: textHeight,
          curve: Curves.decelerate,
          duration: 250.milliseconds,
          color: stateColors.softBackground,
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Opacity(
                opacity: 1,
                child: Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (textOpacity > 0.0)
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: 100.0,
                      child: Divider(
                        thickness: 2.0,
                        color: stateColors.foreground,
                        height: 20.0,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Opacity(
                        opacity: textOpacity,
                        child: Text(
                          widget.summary.length > 90 ?
                          '${widget.summary.substring(0, 87)}...' :
                          widget.summary,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
