import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:supercharged/supercharged.dart';

class DiscoverCard extends StatefulWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String summary;
  final String type;

  DiscoverCard({
    this.id,
    this.imageUrl = '',
    this.name     = '',
    this.summary  = '',
    this.type     = 'reference',
  });

  @override
  _DiscoverCardState createState() => _DiscoverCardState();
}

class _DiscoverCardState extends State<DiscoverCard> {
  double opacity      = 0.5;
  double width        = 270.0;
  double height       = 440.0;
  double elevation    = 3.0;
  double textHeight   = 70.0;
  double textOpacity  = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: AnimatedContainer(
        height: height,
        width: width,
        duration: 250.milliseconds,
        curve: Curves.bounceInOut,
        child: Card(
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
        Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
        ) :
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 80.0,
          ),
          child: Observer(
            builder: (context) {
              return Image.asset(
                widget.type == 'reference' ?
                'assets/images/textbook-${stateColors.iconExt}.png' :
                'assets/images/profile-${stateColors.iconExt}.png',
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
              width = 280.0;
              height = 450.0;
              elevation = 5.0;
            }
            else {
              opacity = 0.5;
              width = 270.0;
              height = 440.0;
              elevation = 3.0;
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
            textHeight = 180.0;
            textOpacity = .3;
          } else {
            textHeight = 70.0;
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
                opacity: .7,
                child: Text(
                  widget.name.length < 15 ?
                    widget.name : '${widget.name.substring(0, 14)}...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
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
