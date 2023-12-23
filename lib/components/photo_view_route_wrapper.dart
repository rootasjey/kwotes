import "dart:async";

import "package:dismissible_page/dismissible_page.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/types/intents/escape_intent.dart";
import "package:photo_view/photo_view.dart";

class HeroPhotoViewRouteWrapper extends StatefulWidget {
  const HeroPhotoViewRouteWrapper({
    super.key,
    required this.imageProvider,
    this.backgroundDecoration,
    this.minScale = 0.3,
    this.maxScale = 2.0,
    this.heroTag = "image_hero",
  });

  /// The image to display.
  final ImageProvider imageProvider;

  /// A widget to display instead of the image.
  final BoxDecoration? backgroundDecoration;

  /// Minimum scale.
  final dynamic minScale;

  /// Maximum scale.
  final dynamic maxScale;

  /// Image hero tag for transition.
  final Object heroTag;

  @override
  createState() => _HeroPhotoViewRouteWrapperState();
}

class _HeroPhotoViewRouteWrapperState extends State<HeroPhotoViewRouteWrapper> {
  /// Photo view controller.
  final PhotoViewController _photoViewController = PhotoViewController();

  /// Whether the page is dismissable.
  /// Blocks dismissable gesture if false.
  bool _pageDismissable = true;

  /// Pop the page if the user zooms out enough (and if this is true).
  bool _isPop = false;

  /// Scale of the image.
  double _scale = 0.9;

  final Map<LogicalKeySet, Intent> _shortcuts = {
    LogicalKeySet(
      LogicalKeyboardKey.escape,
    ): const EscapeIntent(),
  };

  /// Debounce update dimissable.
  Timer? _updateDelay;

  @override
  void initState() {
    super.initState();

    _photoViewController.outputStateStream.listen((event) {
      final double scale = event.scale ?? 1.0;
      _scale = scale;
      if (scale < 0.7 && !_isPop) {
        _isPop = true;
        Navigator.of(context).pop();
      } else if (scale <= 1.0 && !_pageDismissable) {
        _updateDelay?.cancel();
        _updateDelay = Timer(const Duration(milliseconds: 100), () {
          setState(() => _pageDismissable = true);
        });
      } else if (scale > 1.0 && _pageDismissable) {
        _updateDelay?.cancel();
        _updateDelay = Timer(const Duration(milliseconds: 100), () {
          setState(() => _pageDismissable = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _updateDelay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: {
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: onEscapeIntent,
          )
        },
        child: Focus(
          autofocus: true,
          child: DismissiblePage(
            disabled: !_pageDismissable,
            onDismissed: Navigator.of(context).pop,
            child: Container(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              child: Stack(
                children: [
                  PhotoView(
                    initialScale: _scale,
                    imageProvider: widget.imageProvider,
                    backgroundDecoration: widget.backgroundDecoration,
                    minScale: widget.minScale,
                    maxScale: widget.maxScale,
                    controller: _photoViewController,
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: widget.heroTag),
                    scaleStateChangedCallback: (state) {},
                  ),
                  Positioned(
                    top: 24.0,
                    right: 24.0,
                    child: CircleButton(
                      icon: const Icon(TablerIcons.x, color: Colors.white),
                      onTap: Navigator.of(context).pop,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Close this photo view page if the user presses escape key.
  Object? onEscapeIntent(EscapeIntent intent) {
    Navigator.of(context).pop();
    return null;
  }
}
