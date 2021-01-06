import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/reference_page.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';

class ReferenceCard extends StatefulWidget {
  final double elevation;
  final double height;
  final String id;
  final String imageUrl;
  final Function itemBuilder;
  final String name;
  final Function onSelected;
  final EdgeInsetsGeometry padding;
  final double titleFontSize;
  final String type;

  /// Card's width.
  final double width;

  ReferenceCard({
    this.elevation = 3.0,
    this.height = 330.0,
    this.id,
    this.imageUrl = '',
    this.itemBuilder,
    this.name = '',
    this.onSelected,
    this.padding = EdgeInsets.zero,
    this.titleFontSize = 18.0,
    this.type = 'reference',
    this.width = 250.0,
  });

  @override
  _ReferenceCardState createState() => _ReferenceCardState();
}

class _ReferenceCardState extends State<ReferenceCard>
    with TickerProviderStateMixin {
  Animation<double> scaleAnimation;
  AnimationController scaleAnimationController;

  double opacity;
  double width;
  double height;
  double elevation;
  double textOpacity;
  EdgeInsetsGeometry assetImgPadding;

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
      opacity = 0.5;
      textOpacity = 0.0;
      width = widget.width;
      height = widget.height;
      elevation = widget.elevation;

      assetImgPadding = width > 300.0
          ? const EdgeInsets.symmetric(
              horizontal: 80.0,
              vertical: 40.0,
            )
          : const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 35.0,
            );
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
    final isImageOk = widget.imageUrl?.isNotEmpty;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: isImageOk
              ? Ink.image(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                )
              : Padding(
                  padding: assetImgPadding,
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(
                      Icons.library_books,
                      size: widget.width <= 120.0 ? 30.0 : 60.0,
                    ),
                  ),
                ),
        ),
        Positioned.fill(
          child: InkWell(
            onTap: onTap,
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
      height: height,
      width: width,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Card(
          elevation: elevation,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(),
          child: background(),
        ),
      ),
    );
  }

  Widget name() {
    Widget sizedBox = SizedBox(
      width: widget.width - 30.0,
      child: Opacity(
        opacity: 0.6,
        child: Text(
          widget.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: widget.titleFontSize,
          ),
        ),
      ),
    );

    if (widget.name.length > 12) {
      sizedBox = Tooltip(
        message: widget.name,
        child: sizedBox,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: sizedBox,
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

  Future onTap() {
    if (MediaQuery.of(context).size.width > 600.0) {
      return showFlash(
        context: context,
        persistent: false,
        builder: (context, controller) {
          return Flash.dialog(
            controller: controller,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            enableDrag: true,
            margin: const EdgeInsets.only(
              left: 120.0,
              right: 120.0,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
            child: FlashBar(
              message: Container(
                height: MediaQuery.of(context).size.height - 100.0,
                padding: const EdgeInsets.all(60.0),
                child: ReferencePage(
                  id: widget.id,
                ),
              ),
            ),
          );
        },
      );
    }

    return showCupertinoModalBottomSheet(
      context: context,
      builder: (context, scrollController) => ReferencePage(
        id: widget.id,
        scrollController: scrollController,
      ),
    );
  }
}
