import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:rive/rive.dart";

class LikeButton extends StatefulWidget {
  /// A animated heart shapped button (with Rive).
  /// This has been made a standalone component
  /// because of the animation ceremony (e.g. needs a controller).
  const LikeButton({
    super.key,
    this.initialLiked = false,
    this.size = const Size(42.0, 42.0),
    this.tooltip = "",
    this.margin = EdgeInsets.zero,
    this.color,
    this.onPressed,
  });

  /// Initial liked state.
  /// Set to true if you want the animation to start in liked state.
  /// Default to false.
  final bool initialLiked;

  /// Color of the button.
  final Color? color;

  /// Margin around the button.
  final EdgeInsets margin;

  /// Callback fired when the button is pressed.
  final void Function()? onPressed;

  /// Size of the button.
  final Size size;

  /// Tooltip text.
  final String tooltip;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  /// Rive object.
  SMIInput<bool>? _like;

  /// Left position of the button.
  double leftPosition = 9.0;

  /// Top position of the button.
  double topPosition = 7.0;

  @override
  void initState() {
    super.initState();

    // It seems that the button is not fully centered
    // on android. This fixes it.
    if (Utils.graphic.isAndroid()) {
      leftPosition = 8.6;
      topPosition = 5.0;
    }
  }

  @override
  void dispose() {
    _like?.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _like?.value = widget.initialLiked;
    final bool showOverlayIcon =
        _like != null && !(_like!.value) || !widget.initialLiked;

    return Container(
      width: widget.size.width,
      height: widget.size.height,
      padding: widget.margin,
      child: Tooltip(
        message: widget.tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(28.0),
          onTap: () {
            final bool newValue = _like != null ? !_like!.value : true;
            _like?.change(newValue);
            widget.onPressed?.call();
          },
          child: Stack(
            children: [
              RiveAnimation.asset(
                "assets/animations/like-button.riv",
                fit: BoxFit.cover,
                onInit: onInit,
              ),
              if (showOverlayIcon)
                Positioned(
                  left: leftPosition,
                  top: topPosition,
                  child: Icon(
                    TablerIcons.heart,
                    color: widget.color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void onInit(Artboard artboard) {
    final StateMachineController? controller =
        StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );

    if (controller == null) {
      return;
    }

    artboard.addController(controller);
    _like = controller.findInput<bool>("Like");
    _like?.change(widget.initialLiked);
  }
}
