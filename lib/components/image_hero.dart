import "package:flutter/material.dart";
import "package:photo_view/photo_view.dart";

class ImageHero extends StatefulWidget {
  const ImageHero({
    super.key,
    required this.imageProvider,
    this.backgroundDecoration,
    this.minScale = 0.3,
    this.maxScale = 2.0,
  });

  final ImageProvider imageProvider;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  createState() => _ImageHeroState();
}

class _ImageHeroState extends State<ImageHero> {
  PhotoViewController photoViewController = PhotoViewController();
  bool isPop = false;

  @override
  void initState() {
    super.initState();

    photoViewController.outputStateStream.listen((event) {
      final double scale = event.scale ?? 1.0;
      if (scale < widget.minScale && !isPop) {
        isPop = true;
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    photoViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: PhotoView(
        imageProvider: widget.imageProvider,
        backgroundDecoration: widget.backgroundDecoration,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        controller: photoViewController,
        heroAttributes: const PhotoViewHeroAttributes(tag: "image_hero"),
        onTapUp: (context, tapUpDetails, controller) {
          Navigator.of(context).pop();
        },
        scaleStateChangedCallback: (state) {},
      ),
    );
  }
}
