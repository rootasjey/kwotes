import "dart:async";

import "package:beamer/beamer.dart";
import "package:dismissible_page/dismissible_page.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/types/intents/escape_intent.dart";
import "package:photo_view/photo_view.dart";

class HeroPhotoPage extends StatefulWidget {
  const HeroPhotoPage({
    super.key,
    required this.imageProvider,
    this.backgroundDecoration,
    this.minScale = 0.3,
    this.maxScale = 4.0,
    this.heroTag = "image_hero",
    this.initScale,
  });

  /// The image to display.
  final ImageProvider imageProvider;

  /// A widget to display instead of the image.
  final BoxDecoration? backgroundDecoration;

  /// Minimum scale.
  final dynamic minScale;

  /// Maximum scale.
  final dynamic maxScale;

  /// Initial scale.
  final double? initScale;

  /// Image hero tag for transition.
  final Object heroTag;

  @override
  createState() => _HeroPhotoPageState();
}

class _HeroPhotoPageState extends State<HeroPhotoPage> {
  /// Photo view controller.
  final PhotoViewController _photoViewController = PhotoViewController();

  /// Whether the page is dismissable.
  /// Blocks dismissable gesture if false.
  bool _pageDismissable = true;

  /// Pop the page if the user zooms out enough (and if this is true).
  bool _isPop = false;

  /// Scale of the image.
  double _scale = 0.9;

  /// Maximum scale of the image.
  double _maxScale = 4.0;

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
    _scale = widget.initScale ?? _scale;
    _maxScale = _scale * 2;

    _photoViewController.outputStateStream.listen((event) {
      final double scale = event.scale ?? 1.0;
      _scale = scale;
      final double minScale = widget.initScale ?? 0.7;
      if (scale < minScale && !_isPop) {
        _isPop = true;
        context.beamBack();
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
            onDismissed: () {
              context.beamBack();
            },
            child: Stack(
              children: [
                PhotoView(
                  initialScale: _scale,
                  imageProvider: widget.imageProvider,
                  backgroundDecoration: widget.backgroundDecoration,
                  minScale: widget.minScale,
                  maxScale: _maxScale,
                  controller: _photoViewController,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag),
                  scaleStateChangedCallback: (state) {},
                ),
                Positioned(
                  top: 64.0,
                  right: 12.0,
                  child: CircleButton(
                    radius: 16.0,
                    elevation: 8.0,
                    backgroundColor: Colors.white12,
                    shape: const CircleBorder(
                      side: BorderSide(color: Colors.black54, width: 1.0),
                    ),
                    icon: const Icon(
                      TablerIcons.x,
                      size: 16.0,
                      color: Colors.white,
                    ),
                    onTap: context.beamBack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Close this photo view page if the user presses escape key.
  Object? onEscapeIntent(EscapeIntent intent) {
    context.beamBack();
    return null;
  }
}
