import "package:flutter/material.dart";
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
  });

  /// Initial liked state.
  /// Set to true if you want the animation to start in liked state.
  /// Default to false.
  final bool initialLiked;

  /// Size of the button.
  final Size size;

  /// Tooltip text.
  final String tooltip;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  SMIInput<bool>? _like;

  @override
  void dispose() {
    _like?.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: Tooltip(
        message: widget.tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(28.0),
          onTap: () {
            final bool newValue = _like != null ? !_like!.value : true;
            _like?.change(newValue);
          },
          child: RiveAnimation.asset(
            "assets/animations/like-button.riv",
            fit: BoxFit.cover,
            onInit: onInit,
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
